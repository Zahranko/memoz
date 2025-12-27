import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart'; 
import 'package:record/record.dart';
import 'package:memzoProject/core/constant/routes.dart';
import 'package:memzoProject/view/widget/user/LocationPicker.dart';

abstract class AddPostController extends GetxController {
  onFeelingChanged(String? newValue);
  openMap();
  pickImages();
  removeImage(int index);
  submitPost();
  uploadImagesToStorage();

  // Voice Note Methods
  startRecording();
  stopRecording();
  deleteRecording();
}

class AddPostControllerImp extends AddPostController {
  late TextEditingController captionController;
  late TextEditingController locationController;
  late TextEditingController feelingController;

  double? latitude;
  double? longitude;

  var selectedImages = <File>[].obs;
  var isLoading = false.obs;
  var isLocationLoading = false.obs;

  late AudioRecorder audioRecorder;
  var isRecording = false.obs;
  var recordedPath = Rxn<String>();

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  var selectedFeeling = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    captionController = TextEditingController();
    locationController = TextEditingController();
    feelingController = TextEditingController();
    audioRecorder = AudioRecorder();
  }

  @override
  void onClose() {
    audioRecorder.dispose();
    captionController.dispose();
    locationController.dispose();
    feelingController.dispose();
    super.onClose();
  }

  @override
  Future<void> startRecording() async {
    try {
      if (await audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        String fileName =
            'post_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        String path = '${directory.path}/$fileName';

        await audioRecorder.start(const RecordConfig(), path: path);
        isRecording.value = true;
      } else {
        Get.snackbar("Permission", "Microphone permission required.");
      }
    } catch (e) {
      print("Start Recording Error: $e");
    }
  }

  @override
  Future<void> stopRecording() async {
    try {
      final path = await audioRecorder.stop();
      isRecording.value = false;
      if (path != null) {
        recordedPath.value = path; // Save the file path
      }
    } catch (e) {
      print("Stop Recording Error: $e");
    }
  }

  @override
  void deleteRecording() {
    recordedPath.value = null; // Clear the recording
  }

  @override
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
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
          ),
        );

        latitude = position.latitude;
        longitude = position.longitude;
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

  @override
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedImages.addAll(images.map((e) => File(e.path)).toList());
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void removeImage(int index) => selectedImages.removeAt(index);

  @override
  void onFeelingChanged(String? newValue) {
    selectedFeeling.value = newValue;
    feelingController.text = newValue ?? "";
  }

  @override
  Future<void> submitPost() async {
    String caption = captionController.text.trim();
    String location = locationController.text.trim();
    String feeling = feelingController.text.trim();

    // Validation: Require at least an Image OR a Caption
    if ( selectedImages.isEmpty || location.isEmpty) {
      Get.snackbar(
        'Missing Info',
        'Please add a location and (an image or caption).',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      User? user = _auth.currentUser;

      List<String> imageUrls = await uploadImagesToStorage();

      String? audioUrl;
      if (recordedPath.value != null) {
        File audioFile = File(recordedPath.value!);
        String fileName = "voice_${DateTime.now().millisecondsSinceEpoch}.m4a";
        Reference ref = _storage.ref().child('posts_audio/$fileName');
        await ref.putFile(audioFile);
        audioUrl = await ref.getDownloadURL();
      }

      GeoPoint? geoPoint;
      if (latitude != null && longitude != null) {
        geoPoint = GeoPoint(latitude!, longitude!);
      }

      await _firestore.collection('posts').add({
        'userId': user?.uid ?? 'anonymous',
        'caption': caption,
        'locationName': location,
        'locationGeo': geoPoint,
        'feeling': feeling,
        'images': imageUrls,
        'audioUrl': audioUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'userName': user?.displayName ?? 'Unknown User',
        'userAvatar':
            user?.photoURL ??
            'https://miro.medium.com/v2/resize:fit:1080/1*8ATQ6ycC0MkZo4DKMUuGnw.png',
        'likes': [],
        'comments': 0,
      });

      // Clear Data
      captionController.clear();
      locationController.clear();
      feelingController.clear();
      selectedImages.clear();
      selectedFeeling.value = null;
      recordedPath.value = null;
      latitude = null;
      longitude = null;

      Get.offAllNamed(AppRoute.HomeView);
      Get.delete<AddPostControllerImp>();

      Get.snackbar('Success', 'Memo posted successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload post: $e');
    } finally {
      if (Get.isRegistered<AddPostControllerImp>()) {
        isLoading.value = false;
      }
    }
  }

  @override
  Future<List<String>> uploadImagesToStorage() async {
    List<String> downloadUrls = [];
    for (var imageFile in selectedImages) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('posts/$fileName.jpg');
      await ref.putFile(imageFile);
      String url = await ref.getDownloadURL();
      downloadUrls.add(url);
    }
    return downloadUrls;
  }
}
