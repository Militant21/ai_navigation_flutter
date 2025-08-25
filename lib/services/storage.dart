import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KV {
  static Future<void> set(String k, Object v) async { final sp=await SharedPreferences.getInstance(); sp.setString(k, jsonEncode(v)); }
  static Future<T?> get<T>(String k) async { final sp=await SharedPreferences.getInstance(); final s=sp.getString(k); if(s==null) return null; return jsonDecode(s) as T; }
}