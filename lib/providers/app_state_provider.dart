import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateNotifier extends StateNotifier<Map<String, dynamic>> {
  AppStateNotifier() : super({'currentBookName': null, 'readingLogs': []});

  final String _currentBookKey = 'currentBookName';

  Future<void> loadState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? currentBookName = prefs.getString(_currentBookKey);
    state = {...state, 'currentBookName': currentBookName};
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, Map<String, dynamic>>((ref) {
      final notifier = AppStateNotifier();
      notifier.loadState();
      return notifier;
    });
