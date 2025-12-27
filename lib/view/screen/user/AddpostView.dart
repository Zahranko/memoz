import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/addPostController.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/core/constant/routes.dart';
import 'package:memzoProject/view/widget/user/ImagePicker.dart';
import 'package:memzoProject/view/widget/user/addPostInput.dart';
import 'package:memzoProject/view/widget/user/captionInput.dart';
import 'package:memzoProject/view/widget/user/feeling_dropdown.dart';

class AddPostView extends StatelessWidget {
  AddPostView({Key? key}) : super(key: key);

  final AddPostControllerImp controller = Get.put(AddPostControllerImp());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.pagePrimaryColor,
          appBar: AppBar(
            backgroundColor: AppColor.pagePrimaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Get.offAllNamed(AppRoute.HomeView),
            ),
            title: const Text(
              'New Memo',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () => controller.submitPost(),
                child: const Text(
                  'Post',
                  style: TextStyle(
                    color: Color(0xFF5C5470),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Image Picker ---
                  Obx(
                    () => MultiImagePickerBox(
                      images: controller.selectedImages.toList(),
                      onAddTap: () => controller.pickImages(),
                      onRemoveTap: (index) => controller.removeImage(index),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Caption Input ---
                  CaptionInput(controller: controller.captionController),

                  const SizedBox(height: 12),

                  // --- 🎙️ Voice Note Input Section ---
                  Obx(() {
                    // 1. If Recording: Show Recording UI
                    if (controller.isRecording.value) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.mic, color: Colors.red),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Recording...",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => controller.stopRecording(),
                              child: const CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 18,
                                child: Icon(
                                  Icons.stop,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    // 2. If Recorded: Show "File Attached" UI
                    else if (controller.recordedPath.value != null) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.audiotrack, color: Colors.green),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Voice Note Attached",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                              ),
                              onPressed: () => controller.deleteRecording(),
                            ),
                          ],
                        ),
                      );
                    }
                    // 3. Idle: Show "Add Voice Note" Button
                    else {
                      return GestureDetector(
                        onTap: () => controller.startRecording(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
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
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }),

                  const SizedBox(height: 20),

                  // --- Location Input ---
                  GestureDetector(
                    onTap: () => controller.openMap(),
                    child: AbsorbPointer(
                      child: Obx(() {
                        return AddPostInputRow(
                          icon: Icons.location_on_outlined,
                          hintText:
                              controller.isLocationLoading.value
                                  ? 'Finding current location...'
                                  : 'Tap to get location',
                          controller: controller.locationController,
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Feeling Dropdown ---
                  Obx(
                    () => FeelingDropdown(
                      feelings: controller.feelingsList,
                      selectedValue: controller.selectedFeeling.value,
                      onChanged:
                          (newValue) => controller.onFeelingChanged(newValue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- Loading Overlay ---
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
}
