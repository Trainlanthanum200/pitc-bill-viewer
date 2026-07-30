import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_ref.dart';

class StorageService {
  static const _key = "saved_refs";

  static Future<List<SavedRef>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List;
    return list.map((e) => SavedRef.fromJson(e)).toList();
  }

  static Future<void> saveAll(List<SavedRef> refs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(refs.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  static Future<void> add(SavedRef ref) async {
    final all = await loadAll();
    all.add(ref);
    await saveAll(all);
  }

  static Future<void> remove(String id) async {
    final all = await loadAll();
    all.removeWhere((e) => e.id == id);
    await saveAll(all);
  }
}

