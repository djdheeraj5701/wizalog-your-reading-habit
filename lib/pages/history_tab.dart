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
        final completedBooks = bookBox.values
            .where((b) => b.status == BookStatus.completed)
            .toList();

        return ValueListenableBuilder(
          valueListenable: Hive.box<ReadLog>('readLogs').listenable(),
          builder: (context, readLogBox, _) {
            final allReadLogs = readLogBox.values.toList();

            if (completedBooks.isEmpty && allReadLogs.isEmpty) {
              return const Center(child: Text('Your history is empty.'));
            }

            return ListView(
              children: [
                if (completedBooks.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Completed Books',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: completedBooks.length,
                      itemBuilder: (context, index) {
                        final book = completedBooks[index];
                        final lastLog =
                        allReadLogs
                            .where(
                              (log) => log.bookId == book.key.toString(),
                        )
                            .toList()
                          ..sort(
                                (a, b) => b.timestamp.compareTo(a.timestamp),
                          );
                        final completionDate = lastLog.isNotEmpty
                            ? DateFormat.yMd().format(lastLog.first.timestamp)
                            : 'N/A';

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: 120,
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child:
                                    book.imageUrl != null &&
                                        book.imageUrl!.isNotEmpty
                                        ? Image.network(
                                      book.imageUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.book,
                                          size: 80,
                                        ),
                                      ),
                                    )
                                        : const Center(
                                      child: Icon(Icons.book, size: 80),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Expanded(
                                  child: Text(
                                    book.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Completed: $completionDate',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Recent Readings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ...allReadLogs.reversed.map((log) {
                  final bookName = bookBox.values
                      .firstWhere(
                        (b) => b.key.toString() == log.bookId,
                    orElse: () => Book()..name = 'Unknown',
                  )
                      .name;
                  return ListTile(
                    title: Text(bookName),
                    subtitle: Text(
                      'Read ${log.pagesRead} pages on ${DateFormat('MMM d, hh:mm a').format(log.timestamp)}',
                    ),
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
