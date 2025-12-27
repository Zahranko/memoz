import 'package:flutter/material.dart';

class FeelingDropdown extends StatelessWidget {
  final List<Map<String, String>> feelings;
  final String? selectedValue;
  final Function(String?) onChanged;

  const FeelingDropdown({
    Key? key,
    required this.feelings,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Row(
            children: [
              Icon(Icons.emoji_emotions_outlined, color: Colors.grey[400]),
              const SizedBox(width: 10),
              Text(
                'How are you feeling?',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
              size: 20,
            ),
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16), // Rounds the popup menu
          elevation: 4,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          onChanged: onChanged,
          items:
              feelings.map((Map<String, String> item) {
                String value = "${item['emoji']} ${item['name']}";
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Text(
                        item['emoji']!,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item['name']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
