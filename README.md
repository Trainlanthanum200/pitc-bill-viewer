# ⚡ PITC Bill Viewer

A Flutter app to check electricity bills from any Pakistani DISCO (IESCO, LESCO, FESCO, GEPCO, MEPCO, PESCO, HESCO, SEPCO, QESCO, TESCO) using your 14-digit reference number — instantly, right from your phone.

> ⚠️ **Disclaimer:** This is an independent, unofficial app. It is **not affiliated with, endorsed by, or connected to** PITC, WAPDA, or any Pakistani government body or electricity distribution company. It simply fetches publicly available bill information from the official PITC billing portal (`bill.pitc.com.pk`) for personal convenience. For billing disputes, payments, or official matters, please contact your respective electricity company directly.

## Features

- 📱 Works fully on-device — no backend server required
- 🏢 Supports all 10 Pakistani DISCOs, each with its own theme color
- 💾 Save multiple reference numbers with custom labels (e.g. "Ghar", "Dukan")
- 💰 3-tier payment breakdown (within due date / till a date / after due date)
- 📊 12-month bill payment history
- 🌐 View the exact official bill page in-app
- 🖼️ Save bill as an image to your gallery

## Tech Stack

- **Flutter** (Dart) — cross-platform mobile app
- **Dio + cookie_jar** — handles the ASP.NET WebForms session flow needed to fetch bills
- **html** package — parses the bill HTML directly on-device
- **shared_preferences** — local storage for saved reference numbers
- **webview_flutter** — displays the official bill page

## Getting Started

```bash
git clone https://github.com/xeecode/pitc-bill-viewer.git
cd pitc-bill-viewer
flutter pub get
flutter run
```

## Download

Pre-built APKs are available under [Releases](../../releases) — no need to build from source.

## License

This project is for educational and personal-use purposes.
