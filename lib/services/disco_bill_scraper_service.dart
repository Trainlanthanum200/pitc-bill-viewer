// disco_bill_scraper_service.dart

import 'package:flutter/material.dart' hide Element;
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

// =============================================================================
// DISCO (electricity distribution company) list with Theme Colors
// =============================================================================
class Disco {
  final String code; // used in the URL, e.g. "mepcobill"
  final String shortName; // e.g. "MEPCO"
  final String fullName; // e.g. "Multan Electric Power Company"
  final Color themeColor; // Company accent theme color

  const Disco({
    required this.code,
    required this.shortName,
    required this.fullName,
    required this.themeColor,
  });
}

const List<Disco> kDiscoList = [
  Disco(
    code: "iescobill",
    shortName: "IESCO",
    fullName: "Islamabad Electric Supply Company",
    themeColor: Color(0xFF00B894), // Emerald Green
  ),
  Disco(
    code: "lescobill",
    shortName: "LESCO",
    fullName: "Lahore Electric Supply Company",
    themeColor: Color(0xFF0984E3), // Vibrant Blue
  ),
  Disco(
    code: "fescobill",
    shortName: "FESCO",
    fullName: "Faisalabad Electric Supply Company",
    themeColor: Color(0xFF6C63FF), // Indigo / Purple
  ),
  Disco(
    code: "gepcobill",
    shortName: "GEPCO",
    fullName: "Gujranwala Electric Power Company",
    themeColor: Color(0xFFD63031), // Deep Red
  ),
  Disco(
    code: "mepcobill",
    shortName: "MEPCO",
    fullName: "Multan Electric Power Company",
    themeColor: Color(0xFFFF6B35), // Electric Orange
  ),
  Disco(
    code: "pescobill",
    shortName: "PESCO",
    fullName: "Peshawar Electric Supply Company",
    themeColor: Color(0xFFE84393), // Magenta / Pink
  ),
  Disco(
    code: "hescobill",
    shortName: "HESCO",
    fullName: "Hyderabad Electric Supply Company",
    themeColor: Color(0xFF00CEC9), // Teal Cyan
  ),
  Disco(
    code: "sepcobill",
    shortName: "SEPCO",
    fullName: "Sukkur Electric Power Company",
    themeColor: Color(0xFFE17055), // Coral Red
  ),
  Disco(
    code: "qescobill",
    shortName: "QESCO",
    fullName: "Quetta Electric Supply Company",
    themeColor: Color(0xFF636E72), // Slate Grey
  ),
  Disco(
    code: "tescobill",
    shortName: "TESCO",
    fullName: "Tribal Electric Supply Company",
    themeColor: Color(0xFF2D3436), // Charcoal Black
  ),
];

Disco discoByCode(String code) {
  return kDiscoList.firstWhere(
    (d) => d.code == code,
    orElse: () => kDiscoList.firstWhere((d) => d.shortName == "MEPCO"),
  );
}

class DiscoScraperException implements Exception {
  final String message;
  DiscoScraperException(this.message);
  @override
  String toString() => message;
}

class DiscoBillScraperService {
  static String _clean(String? text) {
    if (text == null) return "";
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String? _getHiddenField(Document doc, String id) {
    final el = doc.querySelector('#$id');
    return el?.attributes['value'];
  }

  static Future<Map<String, dynamic>> fetchBill({
    required String discoCode,
    required String refNo,
  }) async {
    if (refNo.length != 14 && refNo.length != 10) {
      throw DiscoScraperException("Reference number must be 10 or 14 digits");
    }
    if (int.tryParse(refNo) == null) {
      throw DiscoScraperException("Reference number must contain only digits");
    }

    final searchUrl = "https://bill.pitc.com.pk/$discoCode";

    final cookieJar = CookieJar();
    final dio = Dio(BaseOptions(
      headers: {
        "User-Agent":
            "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.plain,
      validateStatus: (status) => status != null && status < 500,
    ));
    dio.interceptors.add(CookieManager(cookieJar));

    try {
      final resp1 = await dio.get(searchUrl);
      final doc1 = html_parser.parse(resp1.data.toString());

      final viewState = _getHiddenField(doc1, "__VIEWSTATE") ?? "";
      final viewStateGen = _getHiddenField(doc1, "__VIEWSTATEGENERATOR") ?? "";
      final eventValidation = _getHiddenField(doc1, "__EVENTVALIDATION") ?? "";
      final reqTokenEl =
          doc1.querySelector('input[name="__RequestVerificationToken"]');
      final reqToken = reqTokenEl?.attributes['value'] ?? "";

      final resp2 = await dio.post(
        searchUrl,
        data: {
          "__EVENTTARGET": "",
          "__EVENTARGUMENT": "",
          "__LASTFOCUS": "",
          "__VIEWSTATE": viewState,
          "__VIEWSTATEGENERATOR": viewStateGen,
          "__EVENTVALIDATION": eventValidation,
          "rbSearchByList": "refno",
          "searchTextBox": refNo,
          "ruCodeTextBox": "",
          "__RequestVerificationToken": reqToken,
          "btnSearch": "Search",
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) =>
              status != null && (status < 400 || status == 302),
        ),
      );

      String html;
      if (resp2.statusCode == 302 || resp2.statusCode == 301) {
        final location = resp2.headers.value('location');
        if (location == null) {
          throw DiscoScraperException("Server did not return a redirect location");
        }
        final redirectUri = Uri.parse(searchUrl).resolve(location);
        final resp3 = await dio.get(redirectUri.toString());
        html = resp3.data.toString();
      } else {
        html = resp2.data.toString();
      }

      final result = _parseBill(html);
      result["_raw_html"] = html;

      if (result["reference_no"] == null) {
        throw DiscoScraperException(
            "Bill not found. Check the reference number and try again.");
      }

      return result;
    } on DioException catch (e) {
      throw DiscoScraperException(
          "Could not reach the server. Check your internet connection.\n(${e.message})");
    }
  }

  static Map<String, dynamic> _parseBill(String htmlStr) {
    final doc = html_parser.parse(htmlStr);
    final data = <String, String?>{};

    for (final labelDiv in doc.querySelectorAll('div.label-row')) {
      final enSpan = labelDiv.querySelector('span.en-lbl');
      final label = _clean(enSpan?.text ?? labelDiv.text);
      if (label.isEmpty) continue;

      Element? valDiv;
      Element? sibling = labelDiv.nextElementSibling;
      if (sibling != null && sibling.classes.contains('val-space')) {
        valDiv = sibling;
      } else {
        final parent = labelDiv.parent;
        if (parent != null) {
          final children = parent.children;
          final idx = children.indexOf(labelDiv);
          for (int i = idx + 1; i < children.length; i++) {
            if (children[i].classes.contains('val-space')) {
              valDiv = children[i];
              break;
            }
          }
        }
      }

      if (valDiv != null) {
        final value = _clean(valDiv.text);
        if (value.isNotEmpty) data[label] = value;
      }
    }

    for (final row in doc.querySelectorAll('div.charges-bd-row')) {
      final enSpan = row.querySelector('span.charges-bd-en');
      final valSpan = row.querySelector('span.charges-bd-val');
      if (enSpan != null && valSpan != null) {
        final label = _clean(enSpan.text);
        final value = _clean(valSpan.text);
        if (label.isNotEmpty && value.isNotEmpty) data[label] = value;
      }
    }

    final billMonthEl = doc.querySelector(
        'div.right-panel-box .right-section-cell .right-main-val');
    final dueDateEl =
        doc.querySelector('div.right-section-cell--due .right-main-val--due');

    String? readingDate, issueDate;
    for (final cell in doc.querySelectorAll('div.right-grid-cell')) {
      final labelEl = cell.querySelector('span.right-panel-en');
      final valEl = cell.querySelector('span.right-panel-date-val');
      if (labelEl == null || valEl == null) continue;
      final labelText = _clean(labelEl.text);
      if (labelText.contains('READING DATE')) {
        readingDate = _clean(valEl.text);
      } else if (labelText.contains('ISSUE DATE')) {
        issueDate = _clean(valEl.text);
      }
    }

    data['BILL MONTH'] = billMonthEl != null ? _clean(billMonthEl.text) : null;
    data['DUE DATE'] = dueDateEl != null ? _clean(dueDateEl.text) : null;
    data['READING DATE'] = readingDate;
    data['ISSUE DATE'] = issueDate;

    final payableEl = doc.querySelector('div.payable-card-amount');
    data['PAYABLE WITHIN DUE DATE'] =
        payableEl != null ? _clean(payableEl.text) : null;

    final lpTopVals = doc
        .querySelectorAll('div.lp-surcharge-top-val')
        .map((e) => _clean(e.text))
        .toList();
    final lpBottomVals = doc
        .querySelectorAll('div.lp-surcharge-bottom-val')
        .map((e) => _clean(e.text))
        .toList();
    final lpPeriods = doc
        .querySelectorAll('div.lp-surcharge-period')
        .map((e) => _clean(e.text))
        .toList();

    if (lpTopVals.isNotEmpty) data['LP SURCHARGE (WITHIN DUE)'] = lpTopVals[0];
    if (lpTopVals.length >= 2) data['LP SURCHARGE (AFTER DUE)'] = lpTopVals[1];
    if (lpBottomVals.isNotEmpty) data['PAYABLE TILL DATE'] = lpBottomVals[0];
    if (lpBottomVals.length >= 2) {
      data['PAYABLE AFTER DUE DATE'] = lpBottomVals[1];
    }
    if (lpPeriods.isNotEmpty) data['PAYABLE TILL DATE LABEL'] = lpPeriods[0];
    if (lpPeriods.length >= 2) data['PAYABLE AFTER DATE LABEL'] = lpPeriods[1];

    final billHistory = <Map<String, String>>[];
    for (final row in doc.querySelectorAll('div.history-row')) {
      final cells = row.querySelectorAll('div.history-cell');
      if (cells.length < 5) continue;
      final month = _clean(cells[0].text);
      final statusEl = cells[1].querySelector('span.history-status-pill');
      final status = statusEl != null ? _clean(statusEl.text) : "";
      final units = _clean(cells[2].text);
      final billAmt = _clean(cells[3].text);
      final payment = _clean(cells[4].text);
      if (month.isNotEmpty) {
        billHistory.add({
          "month": month,
          "status": status,
          "units": units,
          "bill_amount": billAmt,
          "payment": payment,
        });
      }
    }

    return {
      "reference_no": data["REFERENCE NO"],
      "consumer_id": data["CONSUMER ID"],
      "name_address": data["NAME & ADDRESS"],
      "category": data["CATEGORY"],
      "status": data["STATUS"],
      "tariff": data["TARIFF"],
      "bill_month": data["BILL MONTH"],
      "reading_date": data["READING DATE"],
      "issue_date": data["ISSUE DATE"],
      "due_date": data["DUE DATE"],
      "payable_within_due_date": data["PAYABLE WITHIN DUE DATE"],
      "payable_till_date": data["PAYABLE TILL DATE"],
      "payable_till_date_label": data["PAYABLE TILL DATE LABEL"],
      "payable_after_due_date": data["PAYABLE AFTER DUE DATE"],
      "payable_after_date_label": data["PAYABLE AFTER DATE LABEL"],
      "lp_surcharge_within_due": data["LP SURCHARGE (WITHIN DUE)"],
      "lp_surcharge_after_due": data["LP SURCHARGE (AFTER DUE)"],
      "bill_history": billHistory,
      "meter_no": data["METER NO"],
      "units_consumed": data["UNITS"],
      "previous_reading": data["PREVIOUS READING"],
      "present_reading": data["PRESENT READING"],
      "total_electricity_charges": data["Total Electricity Charges"],
      "subsidies": data["Subsidies"],
      "current_bill": data["Current Bill"],
      "grand_total": data["Grand Total"],
    };
  }
}
