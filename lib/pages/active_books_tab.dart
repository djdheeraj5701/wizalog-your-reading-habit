import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wizalog_your_reading_habit/models/book.dart';
import 'package:wizalog_your_reading_habit/models/book_status.dart';
import 'package:wizalog_your_reading_habit/models/read_log.dart';

class ActiveBooksTab extends StatelessWidget {
  const ActiveBooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Book>('books').listenable(),
      builder: (context, box, _) {
        final activeBooks = box.values.where((b) => b.status == BookStatus.active).toList();
        if (activeBooks.isEmpty) {
          return const Center(child: Text('No active books. Start a new one!'));
        }

        return ListView.builder(
          itemCount: activeBooks.length,
          itemBuilder: (context, index) {
            final book = activeBooks[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(Icons.book), // Placeholder for the book image
                title: Text(book.name),
                subtitle: Text('Read: ${book.totalPagesRead} / ${book.totalPages} pages'),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showLogReadDialog(context, book),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showLogReadDialog(BuildContext context, Book book) async {
    final TextEditingController pagesReadController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Pages for ${book.name}'),
          content: TextField(
            controller: pagesReadController,
            decoration: const InputDecoration(labelText: 'Pages Read'),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Log'),
              onPressed: () {
                final pagesRead = int.tryParse(pagesReadController.text) ?? 0;
                if (pagesRead > 0) {
                  _logRead(book, pagesRead);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _logRead(Book book, int pagesRead) async {
    try {
      final readLogBox = Hive.box<ReadLog>('readLogs');
      final newLog = ReadLog()
        ..bookId = book.key as String
        ..pagesRead = pagesRead
        ..timestamp = DateTime.now();

      await readLogBox.add(newLog);

      // Update the book's progress
      book.totalPagesRead += pagesRead;
      if (book.totalPagesRead >= book.totalPages) {
        book.status = BookStatus.completed;
      }
      await book.save();
    } catch (e) {
      print('Error logging read: $e');
    }
  }
}