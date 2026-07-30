import 'package:flutter/material.dart';
import '../theme.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Important Notice"),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "This is NOT an official government or WAPDA/PITC app.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "This app is an independent, unofficial tool built for personal "
              "convenience. It is not affiliated with, endorsed by, or "
              "connected to PITC (Power Information Technology Company), "
              "WAPDA, or any Pakistani electricity distribution company "
              "(MEPCO, LESCO, FESCO, GEPCO, PESCO, HESCO, SEPCO, QESCO, "
              "TESCO, or IESCO).\n\n"
              "The app simply fetches publicly available bill information "
              "directly from PITC's official billing website "
              "(bill.pitc.com.pk) using your reference number, and displays "
              "it in a more convenient format.\n\n"
              "For any billing disputes, complaints, payments, or official "
              "matters, please contact your respective electricity company "
              "directly or visit their official website.",
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

