import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wizalog_your_reading_habit/providers/app_state_provider.dart';
import 'package:wizalog_your_reading_habit/widgets/new_book_form.dart';
import 'package:wizalog_your_reading_habit/widgets/log_pages_form.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.read(appStateProvider.notifier).loadState();
  }

  void _startNewBook(String bookName) {
    ref.read(appStateProvider.notifier).setCurrentBook(bookName);
  }

  void _logPages(String bookName, int pages, DateTime timestamp) {
    ref.read(appStateProvider.notifier).logPages(bookName, pages, timestamp);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged $pages pages for $bookName')),
    );
  }

  void _finishBook() {
    ref.read(appStateProvider.notifier).setCurrentBook('');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book finished!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final currentBookName = appState['currentBookName'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          if (currentBookName != null && currentBookName.isNotEmpty)
            IconButton(
              onPressed: _finishBook,
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Finish current book',
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: currentBookName == null || currentBookName.isEmpty
            ? Center(
          child: NewBookForm(
            key: const ValueKey('newBookForm'),
            onStartReading: _startNewBook,
          ),
        )
            : Center(
          child: LogPagesForm(
            key: const ValueKey('logPagesForm'),
            bookName: currentBookName,
            onLogPages: (pages, timestamp) => _logPages(currentBookName, pages, timestamp),
            onFinishBook: _finishBook,
          ),
        ),
      ),
    );
  }
}
