import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wizalog_your_reading_habit/models/book.dart';
import 'package:wizalog_your_reading_habit/models/book_status.dart';
import 'package:wizalog_your_reading_habit/models/read_log.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Book>('books').listenable(),
      builder: (context, bookBox, _) {
        final completedBooks = bookBox.values.where((b) => b.status == BookStatus.completed).toList();

        return ValueListenableBuilder(
          valueListenable: Hive.box<ReadLog>('readLogs').listenable(),
          builder: (context, readLogBox, _) {
            final allReadLogs = readLogBox.values.toList();

            // This is where you would build the more complex history view
            // - Calendar Heat map: You would process allReadLogs to count pages per day.
            // - Statistics: You would calculate stats like average reads from allReadLogs.
            // - List of log entries: You can display allReadLogs here.

            if (completedBooks.isEmpty && allReadLogs.isEmpty) {
              return const Center(child: Text('Your history is empty.'));
            }

            return ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Completed Books', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ...completedBooks.map((book) {
                  final lastLog = allReadLogs.where((log) => log.bookId == book.key.toString()).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
                  final completionDate = lastLog.isNotEmpty ? DateFormat.yMd().format(lastLog.first.timestamp) : 'N/A';
                  return ListTile(
                    title: Text(book.name),
                    subtitle: Text('Completed on: $completionDate'),
                  );
                }),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Recent Readings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ...allReadLogs.reversed.map((log) {
                  final bookName = bookBox.values.firstWhere((b) => b.key == log.bookId, orElse: () => Book()..name = 'Unknown').name;
                  return ListTile(
                    title: Text(bookName),
                    subtitle: Text('Read ${log.pagesRead} pages on ${DateFormat.yMd().format(log.timestamp)}'),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}