import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// App-wide constants and theme colors.
// ---------------------------------------------------------------------------

const String kAppName = "PITC Bill Viewer";
const String kGithubUrl = "https://github.com/xeecode";

const Color kPrimary = Color(0xFFFF6B35);
const Color kPrimaryLight = Color(0xFFFFA751);
const Color kBg = Color(0xFFF5F6FA);

/// Builds a 2-color gradient from a single DISCO theme color.
List<Color> discoGradient(Color base) {
  final light = Color.lerp(base, Colors.white, 0.30) ?? base;
  return [base, light];
}
