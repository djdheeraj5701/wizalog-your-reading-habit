import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wizalog_your_reading_habit/models/reading_log.dart';

class AppStateNotifier extends StateNotifier<Map<String, dynamic>> {
  AppStateNotifier() : super({'currentBookName': null, 'readingLogs': []});

  final CollectionReference _logsCollection = FirebaseFirestore.instance.collection('reading_logs');
  final String _currentBookKey = 'currentBookName';

  Future<void> loadState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? currentBookName = prefs.getString(_currentBookKey);
    state = {...state, 'currentBookName': currentBookName};
  }

  Future<void> setCurrentBook(String bookName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentBookKey, bookName);
    state = {
      ...state,
      'currentBookName': bookName,
    };
  }

  Future<void> logPages(String bookName, int pages, DateTime timestamp) async {
    await _logsCollection.add(ReadingLog(
      bookName: bookName,
      pages: pages,
      timestamp: timestamp,
    ).toFirestore());
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, Map<String, dynamic>>((ref) {
  final notifier = AppStateNotifier();
  notifier.loadState();
  return notifier;
});
