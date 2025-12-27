import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/commentsController.dart';

class ReportCommentPage extends StatefulWidget {
  final CommentsController controller;
  final String commentId;

  const ReportCommentPage({
    Key? key, 
    required this.controller, 
    required this.commentId
  }) : super(key: key);

  @override
  State<ReportCommentPage> createState() => _ReportCommentPageState();
}

class _ReportCommentPageState extends State<ReportCommentPage> {
  // Standard reporting reasons similar to Instagram
  final List<String> reasons = [
    "It's spam",
    "Nudity or sexual activity",
    "Hate speech or symbols",
    "Violence or dangerous organizations",
    "Bullying or harassment",
    "False information",
    "Scam or fraud",
    "I just don't like it",
  ];

  String selectedReason = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Why are you reporting this comment?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Your report is anonymous. If someone is in immediate danger, call the local emergency services - don't wait.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: reasons.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final reason = reasons[index];
                return ListTile(
                  title: Text(reason),
                  trailing: selectedReason == reason 
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : const Icon(Icons.circle_outlined, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      selectedReason = reason;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedReason.isEmpty ? Colors.grey[300] : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
                onPressed: selectedReason.isEmpty 
                    ? null 
                    : () {
                        widget.controller.reportComment(widget.commentId, selectedReason);
                      },
                child: const Text(
                  "Submit Report", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}