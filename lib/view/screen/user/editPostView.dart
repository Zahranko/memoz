import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/editPostController.dart';
import 'package:memzoProject/data/model/postsModel.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/view/widget/user/addPostInput.dart';
import 'package:memzoProject/view/widget/user/captionInput.dart';
import 'package:memzoProject/view/widget/user/feeling_dropdown.dart';
import 'package:memzoProject/view/widget/user/AudioCommentBubble.dart'; // Reuse your player bubble

class EditPostView extends StatelessWidget {
  final PostModel post;

  const EditPostView({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EditPostController controller = Get.put(EditPostController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPostDetails(post);
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.pagePrimaryColor,
          appBar: AppBar(
            backgroundColor: AppColor.pagePrimaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: const Text(
              'Edit Memo',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () => controller.saveChanges(post.id),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Color(0xFF5C5470),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. EDITABLE IMAGE GALLERY ---
                SizedBox(
                  height: 120,
                  child: Obx(() {
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // A. Existing Images from URL
                        ...List.generate(controller.existingImages.length, (
                          index,
                        ) {
                          return _buildImageThumbnail(
                            imageProvider: NetworkImage(
                              controller.existingImages[index],
                            ),
                            onDelete:
                                () => controller.removeExistingImage(index),
                          );
                        }),

                        // B. New Local Images
                        ...List.generate(controller.newImages.length, (index) {
                          return _buildImageThumbnail(
                            imageProvider: FileImage(
                              controller.newImages[index],
                            ),
                            onDelete: () => controller.removeNewImage(index),
                          );
                        }),

                        // C. Add Button
                        GestureDetector(
                          onTap: controller.pickImages,
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // --- 2. CAPTION INPUT ---
                CaptionInput(controller: controller.captionController),

                const SizedBox(height: 12),

                // --- 3. AUDIO EDITOR SECTION ---
                Obx(() {
                  // State A: Recording in Progress
                  if (controller.isRecording.value) {
                    return _buildRecordingUI(controller);
                  }
                  // State B: New Recording Ready
                  else if (controller.newRecordedPath.value != null) {
                    return _buildNewAudioUI(controller);
                  }
                  // State C: Existing Audio Present
                  else if (controller.existingAudioUrl.value != null) {
                    return _buildExistingAudioUI(
                      controller,
                      controller.existingAudioUrl.value!,
                    );
                  }
                  // State D: No Audio (Show Add Button)
                  else {
                    return _buildAddAudioButton(controller);
                  }
                }),

                const SizedBox(height: 20),

                // --- 4. LOCATION INPUT ---
                GestureDetector(
                  onTap: () => controller.openMap(),
                  child: AbsorbPointer(
                    child: Obx(
                      () => AddPostInputRow(
                        icon: Icons.location_on_outlined,
                        hintText:
                            controller.isLocationLoading.value
                                ? 'Finding location...'
                                : 'Tap to edit location',
                        controller: controller.locationController,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- 5. FEELING ---
                Obx(
                  () => FeelingDropdown(
                    feelings: controller.feelingsList,
                    selectedValue: controller.selectedFeeling.value,
                    onChanged: controller.onFeelingChanged,
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- LOADING OVERLAY ---
        Obx(() {
          if (controller.isLoading.value) {
            return Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildImageThumbnail({
    required ImageProvider imageProvider,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 5,
          right: 15,
          child: GestureDetector(
            onTap: onDelete,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingUI(EditPostController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.red),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Recording...",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: controller.stopRecording,
            child: const CircleAvatar(
              backgroundColor: Colors.red,
              radius: 18,
              child: Icon(Icons.stop, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewAudioUI(EditPostController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.audiotrack, color: Colors.green),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "New Voice Note Recorded",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: controller.deleteNewRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildExistingAudioUI(EditPostController controller, String url) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, top: 4),
            child: Text(
              "Attached Audio:",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Row(
            children: [
              Expanded(child: AudioCommentBubble(audioUrl: url, isMe: true)),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: "Remove Audio",
                onPressed: controller.deleteExistingAudio,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddAudioButton(EditPostController controller) {
    return GestureDetector(
      onTap: controller.startRecording,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.mic_none, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Text(
              "Tap to Record Audio",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
