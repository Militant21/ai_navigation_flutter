import 'package:flutter_tts/flutter_tts.dart';
final _tts = FlutterTts();
Future<void> speak(String text, String lang) async { await _tts.setLanguage(lang); await _tts.setSpeechRate(1.0); await _tts.speak(text); }