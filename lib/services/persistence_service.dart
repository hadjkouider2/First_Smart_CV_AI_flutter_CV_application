import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cv_model.dart';

class PersistenceService {
  static const String _cvKey = 'saved_cv_profile';

  // Save CV Profile to local storage
  static Future<void> saveCV(CVProfile cv) async {
    final prefs = await SharedPreferences.getInstance();
    final String cvJson = jsonEncode(cv.toMap());
    await prefs.setString(_cvKey, cvJson);
  }

  // Load CV Profile from local storage
  static Future<CVProfile?> loadCV() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cvJson = prefs.getString(_cvKey);
    
    if (cvJson != null && cvJson.isNotEmpty) {
      try {
        final Map<String, dynamic> cvMap = jsonDecode(cvJson);
        return CVProfile.fromMap(cvMap);
      } catch (e) {
        print('Error loading CV from storage: $e');
        return null;
      }
    }
    return null;
  }

  // Clear saved CV
  static Future<void> clearCV() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cvKey);
  }
}
