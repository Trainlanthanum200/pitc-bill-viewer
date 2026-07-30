import 'package:flutter/material.dart';
import '../theme.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.add_circle_outline_rounded,
        "Add a Reference Number",
        "Tap 'Add Number' on the home screen. Select your electricity "
            "company, give it a label (e.g. 'Ghar', 'Dukan'), and enter your "
            "14-digit reference number (found on your printed bill)."
      ),
      (
        Icons.touch_app_outlined,
        "View Your Bill",
        "Tap any saved card to instantly fetch and view the latest bill — "
            "amounts, due dates, meter readings, and 12-month history."
      ),
      (
        Icons.open_in_new_rounded,
        "Open Your Bill",
        "Tap 'Open Your Bill' to view the exact official bill layout, "
            "just like on the PITC website."
      ),
      (
        Icons.download_rounded,
        "Save to Gallery",
        "From the official bill view, tap the download icon to save the "
            "bill image to your phone's gallery."
      ),
      (
        Icons.refresh_rounded,
        "Refresh Anytime",
        "Tap the refresh icon on any bill screen to fetch the latest data."
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("How to Use"),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: steps.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final (icon, title, desc) = steps[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: kPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${index + 1}. $title",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

