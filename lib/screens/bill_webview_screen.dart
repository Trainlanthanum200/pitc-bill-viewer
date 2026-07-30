import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:universal_html/html.dart' as html;
import '../theme.dart';

class BillWebViewScreen extends StatefulWidget {
  final String html;
  final String title;
  final Color themeColor;

  const BillWebViewScreen({
    super.key,
    required this.html,
    required this.title,
    required this.themeColor,
  });

  @override
  State<BillWebViewScreen> createState() => _BillWebViewScreenState();
}

class _BillWebViewScreenState extends State<BillWebViewScreen> {
  late final WebViewController _controller;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _loading = true;
  bool _saving = false;

  /// Clean viewport & CSS injection to make 1000px PITC Bill fit automatically on mobile
  String _prepareHtmlForMobile(String rawHtml) {
    const customHeadFixes = '''
    <meta name="viewport" content="width=1000, initial-scale=0.38, minimum-scale=0.1, maximum-scale=3.0, user-scalable=yes">
    <style>
      html, body {
        width: 1000px !important;
        margin: 0 auto !important;
        padding: 0 !important;
        background-color: #ffffff !important;
      }
      /* Hide web navbar, header, print buttons */
      .navbar, nav, header, #printButton, .no-print, input[type="button"], button {
        display: none !important;
      }
      /* Center alignment */
      #form1, .page, .container, table {
        margin: 0 auto !important;
      }
    </style>
    ''';

    if (rawHtml.contains('<head>')) {
      return rawHtml.replaceFirst('<head>', '<head>$customHeadFixes');
    }
    return '$customHeadFixes$rawHtml';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadHtmlString(_prepareHtmlForMobile(widget.html),
          baseUrl: "https://bill.pitc.com.pk/");
  }

  Future<void> _saveToGallery() async {
    setState(() => _saving = true);
    try {
      final imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes == null) {
        throw Exception("Could not capture the bill");
      }

      if (kIsWeb) {
        final blob = html.Blob([imageBytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '${widget.title}_bill.png')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        await Gal.putImageBytes(imageBytes, name: '${widget.title}_bill');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved to Gallery")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not save: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _saving ? null : _saveToGallery,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_rounded),
            tooltip: "Save to Gallery",
          ),
        ],
      ),
      body: Stack(
        children: [
          Screenshot(
            controller: _screenshotController,
            child: WebViewWidget(controller: _controller),
          ),
          if (_loading)
            Container(
              color: kBg,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
