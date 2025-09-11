import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wizalog_your_reading_habit/misc/theme.dart';
import 'package:wizalog_your_reading_habit/pages/home_page.dart';

import 'models/book.dart';
import 'models/book_status.dart';
import 'models/read_log.dart';

// part 'FILE.g.dart'; // This file will be generated automatically by running `flutter pub run build_runner build`

void main() async {
  // Initialize Hive
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register the generated adapters
  Hive.registerAdapter(BookStatusAdapter());
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(ReadLogAdapter());

  // Open the Hive boxes (think of these as tables in a traditional database)
  await Hive.openBox<Book>('books');
  await Hive.openBox<ReadLog>('readLogs');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WizAlog',
      theme: wizalogTheme,
      home: const HomePage(),
    );
  }
}
