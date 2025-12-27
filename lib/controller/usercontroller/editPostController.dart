import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:memzoProject/controller/usercontroller/profilePageController.dart';
import 'package:memzoProject/data/model/postsModel.dart';
import 'package:memzoProject/view/widget/user/LocationPicker.dart';

class EditPostController extends GetxController {
  // --- Text Controllers ---
  late TextEditingController captionController;
  late TextEditingController locationController;

  // --- Reactive Variables ---
  var selectedFeeling = Rxn<String>();
  var isLoading = false.obs;
  var isLocationLoading = false.obs;

  // --- 📸 Image Variables ---
  // We keep track of existing URLs (to keep) and New Files (to upload) separately
  var existingImages = <String>[].obs;
  var newImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  // --- 🎙️ Audio Variables ---
  late AudioRecorder audioRecorder;
  var isRecording = false.obs;

  // existingAudioUrl: The URL currently saved in Firestore
  var existingAudioUrl = Rxn<String>();
  // recordedPath: The path of a NEW recording (if user replaced the audio)
  var newRecordedPath = Rxn<String>();
  // Flag: Did the user explicitly delete the old audio?
  bool _wasAudioDeleted = false;

  // --- Location ---
  double? latitude;
  double? longitude;

  // --- Dependencies ---
  final ProfileController profileController = Get.find<ProfileController>();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<Map<String, String>> feelingsList = [
    {'name': 'Happy', 'emoji': '😊'},
    {'name': 'Excited', 'emoji': '🤩'},
    {'name': 'Loved', 'emoji': '🥰'},
    {'name': 'Grateful', 'emoji': '🙏'},
    {'name': 'Proud', 'emoji': '😎'},
    {'name': 'Sad', 'emoji': '😔'},
    {'name': 'Angry', 'emoji': '😡'},
    {'name': 'Tired', 'emoji': '😴'},
    {'name': 'Confused', 'emoji': '🤔'},
    {'name': 'Relaxed', 'emoji': '😌'},
  ];

  @override
  void onInit() {
    super.onInit();
    captionController = TextEditingController();
    locationController = TextEditingController();
    audioRecorder = AudioRecorder();
  }

  @override
  void onClose() {
    audioRecorder.dispose();
    captionController.dispose();
    locationController.dispose();
    super.onClose();
  }

  // --- Load Data ---
  void loadPostDetails(PostModel post) {
    captionController.text = post.caption;
    locationController.text = post.locationName;
    selectedFeeling.value = post.feeling;

    // Load Images
    existingImages.assignAll(post.images);
    newImages.clear();

    // Load Audio
    existingAudioUrl.value = post.audioUrl;
    newRecordedPath.value = null;
    _wasAudioDeleted = false;

    // Optional: Load lat/long if available in model
    // latitude = post.latitude;
    // longitude = post.longitude;
  }

  // --- 📸 Image Logic ---
  Future<void> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        newImages.addAll(pickedFiles.map((e) => File(e.path)));
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  void removeExistingImage(int index) {
    existingImages.removeAt(index);
  }

  void removeNewImage(int index) {
    newImages.removeAt(index);
  }

  // --- 🎙️ Audio Logic ---

  // 1. Delete Existing Audio
  void deleteExistingAudio() {
    existingAudioUrl.value = null;
    _wasAudioDeleted = true;
  }

  // 2. Start Recording
  Future<void> startRecording() async {
    try {
      if (await audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        String fileName =
            'edit_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        String path = '${directory.path}/$fileName';

        await audioRecorder.start(const RecordConfig(), path: path);
        isRecording.value = true;

        // If we start recording, we assume we are replacing any old audio
        deleteExistingAudio();
      } else {
        Get.snackbar("Permission", "Microphone permission required.");
      }
    } catch (e) {
      print("Start Recording Error: $e");
    }
  }

  // 3. Stop Recording
  Future<void> stopRecording() async {
    try {
      final path = await audioRecorder.stop();
      isRecording.value = false;
      if (path != null) {
        newRecordedPath.value = path;
      }
    } catch (e) {
      print("Stop Recording Error: $e");
    }
  }

  // 4. Delete New Recording
  void deleteNewRecording() {
    newRecordedPath.value = null;
  }

  // --- 🌍 Location Logic (Auto-GPS) ---
  void openMap() async {
    if (latitude == null || longitude == null) {
      try {
        isLocationLoading.value = true;
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          isLocationLoading.value = false;
          _navigateToMap();
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            isLocationLoading.value = false;
            _navigateToMap();
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          isLocationLoading.value = false;
          _navigateToMap();
          return;
        }

        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, // New way to set accuracy
            distanceFilter:
                100, // Optional: Update location only when moved 100m
          ),
        );

        latitude = position.latitude;
        longitude = position.longitude;

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          locationController.text =
              "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}";
        }
      } catch (e) {
        print("Error getting location: $e");
      } finally {
        isLocationLoading.value = false;
      }
    }
    _navigateToMap();
  }

  void _navigateToMap() async {
    var result = await Get.to(
      () => LocationPickerView(initialLat: latitude, initialLng: longitude),
    );

    if (result != null) {
      locationController.text = result['address'];
      latitude = result['lat'];
      longitude = result['lng'];
    }
  }

  void onFeelingChanged(String? newValue) {
    selectedFeeling.value = newValue;
  }

  // --- 💾 Save Changes ---
  Future<void> saveChanges(String postId) async {
    String caption = captionController.text.trim();
    String location = locationController.text.trim();
    String feeling = selectedFeeling.value ?? "";

    if (caption.isEmpty && existingImages.isEmpty && newImages.isEmpty) {
      Get.snackbar('Error', 'Memo cannot be empty');
      return;
    }

    isLoading.value = true;

    try {
      // 1. Upload New Images
      List<String> uploadedImageUrls = [];
      for (var file in newImages) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = _storage.ref().child('posts/$fileName.jpg');
        await ref.putFile(file);
        String url = await ref.getDownloadURL();
        uploadedImageUrls.add(url);
      }

      // Combine Old + New Images
      List<String> finalImages = [...existingImages, ...uploadedImageUrls];

      // 2. Handle Audio Upload
      String? finalAudioUrl = existingAudioUrl.value;

      // If user recorded a new one, upload it and replace
      if (newRecordedPath.value != null) {
        File audioFile = File(newRecordedPath.value!);
        String fileName =
            "voice_edit_${DateTime.now().millisecondsSinceEpoch}.m4a";
        Reference ref = _storage.ref().child('posts_audio/$fileName');
        await ref.putFile(audioFile);
        finalAudioUrl = await ref.getDownloadURL();
      }
      // If user deleted old audio and didn't record new one
      else if (_wasAudioDeleted) {
        finalAudioUrl = null;
      }

      // 3. Update via ProfileController
      // Note: You need to update your ProfileController.editPost to accept these new params
      // Or call Firestore directly here:
      await profileController.updatePostData(postId, {
        'caption': caption,
        'locationName': location,
        'feeling': feeling,
        'images': finalImages,
        'audioUrl': finalAudioUrl,
        // 'locationGeo': GeoPoint(lat, long) // Add if you want to update coords
      });

      Get.back();
      Get.snackbar('Success', 'Memo updated successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update post: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
