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
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                leading: book.imageUrl != null && book.imageUrl!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    book.imageUrl!,
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.book, size: 50),
                  ),
                )
                    : const Icon(Icons.book, size: 50),
                title: Text(book.name),
                subtitle: Text('Read: ${book.totalPagesRead} / ${book.totalPages} pages'),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showLogReadDialog(context, book),
                ),
                onLongPress: () => _showDeleteBookDialog(context, book),
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
        int pagesRead = 0;
        double progress = book.totalPagesRead / book.totalPages;
        String errorMessage = '';
        DateTime selectedDate = DateTime.now();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  if (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        book.imageUrl!,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.book, size: 100),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(book.name),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pagesReadController,
                    decoration: InputDecoration(
                      labelText: 'Pages Read',
                      border: const OutlineInputBorder(),
                      errorText: errorMessage.isNotEmpty ? errorMessage : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        pagesRead = int.tryParse(value) ?? 0;
                        if (book.totalPagesRead + pagesRead > book.totalPages) {
                          errorMessage = 'Pages read cannot exceed ${book.totalPages - book.totalPagesRead}';
                        } else {
                          errorMessage = '';
                        }
                        progress = (book.totalPagesRead + pagesRead) / book.totalPages;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('MMM dd, yyyy hh:mm a').format(selectedDate),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDate),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                      'Progress: ${book.totalPagesRead + pagesRead} / ${book.totalPages} pages'),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  onPressed: pagesRead > 0 && errorMessage.isEmpty
                      ? () async {
                    await _logRead(book, pagesRead, selectedDate);
                    Navigator.of(context).pop();
                  }
                      : null,
                  child: const Text('Log'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteBookDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              _deleteBook(book);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _deleteBook(Book book) {
    try {
      book.delete();
      // You may also want to delete associated logs here if needed
    } catch (e) {
      print('Error deleting book: $e');
    }
  }

  Future<void> _logRead(Book book, int pagesRead, DateTime timestamp) async {
    try {
      final readLogBox = Hive.box<ReadLog>('readLogs');
      final newLog = ReadLog()
        ..bookId = book.key.toString()
        ..pagesRead = pagesRead
        ..timestamp = timestamp;

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
