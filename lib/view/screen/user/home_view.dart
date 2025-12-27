import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/feedController.dart';
import 'package:memzoProject/controller/usercontroller/navbar_controller.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/view/screen/user/ExoploreView.dart';
import 'package:memzoProject/view/screen/user/ProfilePageView.dart';
import 'package:memzoProject/view/screen/user/navbar_view.dart';
import 'package:memzoProject/view/widget/user/header.dart';
import 'package:memzoProject/view/widget/user/postCard.dart';
import 'package:memzoProject/view/screen/chat/inboxView.dart';
// 1. IMPORT MEMO DETAIL VIEW
import 'package:memzoProject/view/screen/user/memoDetailView.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NavBarController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.pagePrimaryColor,
      body: SafeArea(
        child: Obx(() {
          final idx = Get.find<NavBarController>().currentIndex.value;

          return IndexedStack(
            index: idx,
            children: [FeedView(), ExploreView(), InboxView(), ProfileView()],
          );
        }),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

class FeedView extends StatelessWidget {
  final FeedControllerImp controller = Get.put(FeedControllerImp());

  FeedView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.pagePrimaryColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              AppHeader(),

              const SizedBox(height: 20),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Empty State
                  if (controller.posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Follow people to see their memos here!",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.posts.length,
                    separatorBuilder:
                        (ctx, index) => const SizedBox(height: 30),
                    itemBuilder: (context, index) {
                      final post = controller.posts[index];

                      return PostCard(
                        post: post,
                        onLike: () => controller.toggleLike(post.id),
                        // 2. ADD NAVIGATION ON TAP
                        onPostTap: () {
                          Get.to(
                            () => MemoDetailView(
                              initialPost: post,
                              sourceList: controller.posts,
                              onToggleLike: (id) => controller.toggleLike(id),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
