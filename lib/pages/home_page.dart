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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Listen for tab changes to rebuild the widget and show/hide the FAB
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  // A helper method to build the FAB based on the current tab
  Widget? _buildFloatingActionButton() {
    if (_tabController.index == 1) {
      // History tab
      return null;
    }

    if (_tabController.index == 0) {
      // Active tab
      return FloatingActionButton(
        onPressed: () => _showAddBookBottomSheet(
          context,
          sheetHeader: 'Start a new Read',
          status: BookStatus.active,
        ),
        child: const Icon(Icons.add),
      );
    }

    if (_tabController.index == 2) {
      // Wishlist tab
      return FloatingActionButton(
        onPressed: () => _showAddBookBottomSheet(
          context,
          sheetHeader: 'Add to Wishlist',
          status: BookStatus.wishlist,
        ),
        child: const Icon(Icons.add),
      );
    }
    return null;
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
        children: const [ActiveBooksTab(), HistoryTab(), WishlistTab()],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // A modal bottom sheet to add a new book with more fields
  void _showAddBookBottomSheet(
    BuildContext context, {
    required String sheetHeader,
    required BookStatus status,
  }) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController totalPagesController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();

    // State variable to hold the image URL for preview
    String? imageUrlPreview;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
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
                          sheetHeader,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        if (imageUrlPreview != null &&
                            imageUrlPreview!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                imageUrlPreview!,
                                fit: BoxFit.contain,
                                height: 150,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 150,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
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
                          onChanged: (value) {
                            setState(() {
                              imageUrlPreview = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Image URL (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            final bookName = nameController.text;
                            final totalPages =
                                int.tryParse(totalPagesController.text) ?? 0;
                            final imageUrl = imageUrlController.text;
                            if (bookName.isNotEmpty && totalPages > 0) {
                              _addBook(bookName, totalPages, imageUrl, status);
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
          ),
        );
      },
    );
  }

  // Function to add a new book to the Hive database
  void _addBook(
    String name,
    int totalPages,
    String imageUrl,
    BookStatus status,
  ) async {
    try {
      final bookBox = Hive.box<Book>('books');
      final newBook = Book()
        ..name = name
        ..totalPages = totalPages
        ..totalPagesRead = 0
        ..imageUrl = imageUrl
        ..status = status;

      await bookBox.add(newBook);
      setState(() {}); // Rebuild the widget to show the new book
    } catch (e) {
      print('Error adding book: $e');
    }
  }
}
