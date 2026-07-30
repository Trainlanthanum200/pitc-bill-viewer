import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/disco_bill_scraper_service.dart';
import '../widgets/bill_card.dart';
import 'bill_webview_screen.dart';

class BillScreen extends StatefulWidget {
  final String refNo;
  final String? label;
  final String discoCode;

  const BillScreen({
    super.key,
    required this.refNo,
    required this.discoCode,
    this.label,
  });

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _bill;

  @override
  void initState() {
    super.initState();
    _fetchBill();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Opens the official PITC bill page in an in-app WebView
  void _openBillView() {
    final rawHtml = _bill?["_raw_html"]?.toString();
    if (rawHtml == null || rawHtml.isEmpty) {
      _showSnack("Bill page not available");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BillWebViewScreen(
          html: rawHtml,
          title: widget.label ?? "Bill",
          themeColor: discoByCode(widget.discoCode).themeColor,
        ),
      ),
    );
  }

  Future<void> _fetchBill() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await DiscoBillScraperService.fetchBill(
        discoCode: widget.discoCode,
        refNo: widget.refNo,
      );
      setState(() {
        _bill = result;
      });
    } on DiscoScraperException catch (e) {
      setState(() {
        _error = e.toString();
      });
    } catch (e) {
      setState(() {
        _error = "Something went wrong: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final disco = discoByCode(widget.discoCode);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label ?? "Bill"),
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: _loading ? null : _fetchBill,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: BillCard(
                      bill: _bill!,
                      disco: disco,
                      onOpenBill: _openBillView,
                    ),
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBill,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}

