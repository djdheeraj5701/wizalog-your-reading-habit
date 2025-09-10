import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wizalog_your_reading_habit/models/book.dart';
import 'package:wizalog_your_reading_habit/models/book_status.dart';
import 'package:url_launcher/url_launcher.dart';

import 'active_books_tab.dart';
import 'history_tab.dart';
import 'wishlist_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WizAlog'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
            Tab(text: 'Wishlist'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ActiveBooksTab(),
          HistoryTab(),
          WishlistTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBookBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // A modal bottom sheet to add a new book with more fields
  void _showAddBookBottomSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController totalPagesController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bc).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Start a New Book',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Book Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: totalPagesController,
                    decoration: InputDecoration(
                      labelText: 'Total Pages',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'Image URL (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.link),
                        onPressed: () async {
                          final url = Uri.tryParse(imageUrlController.text);
                          if (url != null && await canLaunchUrl(url)) {
                            launchUrl(url);
                          } else {
                            // Optionally show a toast or message that the URL is invalid
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid URL')),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final bookName = nameController.text;
                      final totalPages = int.tryParse(totalPagesController.text) ?? 0;
                      final imageUrl = imageUrlController.text;
                      if (bookName.isNotEmpty && totalPages > 0) {
                        _addBook(bookName, totalPages, imageUrl);
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.add_task),
                    label: const Text('Add Book'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to add a new book to the Hive database
  void _addBook(String name, int totalPages, String imageUrl) async {
    try {
      final bookBox = Hive.box<Book>('books');
      final newBook = Book()
        ..name = name
        ..totalPages = totalPages
        ..totalPagesRead = 0
        ..imageUrl = imageUrl
        ..status = BookStatus.active;

      await bookBox.add(newBook);
      setState(() {}); // Rebuild the widget to show the new book
    } catch (e) {
      print('Error adding book: $e');
    }
  }
}
