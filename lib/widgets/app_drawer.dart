import 'package:flutter/material.dart';
import '../theme.dart';
import '../screens/disclaimer_screen.dart';
import '../screens/how_to_use_screen.dart';
import '../screens/github_link_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, kPrimaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.electric_bolt_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    kAppName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Unofficial · Made by xeecode",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: kPrimary),
              title: const Text("Important Notice"),
              subtitle: const Text("This is not an official government app",
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DisclaimerScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded, color: kPrimary),
              title: const Text("How to Use"),
              subtitle: const Text("Quick guide to using this app",
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HowToUseScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.code_rounded, color: kPrimary),
              title: const Text("Rate on GitHub"),
              subtitle: const Text("github.com/xeecode",
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GithubLinkScreen()),
                );
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "v1.0 — built independently using PITC's public billing portal",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

