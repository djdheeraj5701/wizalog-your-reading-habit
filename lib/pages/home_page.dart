import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wizalog_your_reading_habit/models/book.dart';
import 'package:wizalog_your_reading_habit/models/book_status.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final TextEditingController searchController = TextEditingController();

    // State variables for search results
    List<dynamic> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Calculate 75% of the screen height
            final screenHeight = MediaQuery.of(context).size.height;
            final sheetHeight = screenHeight * 0.75;

            // Method to perform the book search
            Future<void> _searchBooks() async {
              setState(() {
                isSearching = true;
                searchResults.clear();
              });
              final query = searchController.text.trim();
              if (query.isEmpty) {
                setState(() {
                  isSearching = false;
                });
                return;
              }

              try {
                final response = await http.get(
                  Uri.parse(
                      'https://www.googleapis.com/books/v1/volumes?q=$query'),
                );

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);
                  setState(() {
                    searchResults = data['items'] ?? [];
                    isSearching = false;
                  });
                } else {
                  setState(() {
                    isSearching = false;
                  });
                  // Show a snackbar for error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to load search results.')),
                  );
                }
              } catch (e) {
                setState(() {
                  isSearching = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }

            // Method to select a book from search results
            void _selectBookFromSearch(Map<String, dynamic> item) {
              final volumeInfo = item['volumeInfo'] ?? {};
              final name = volumeInfo['title'] ?? 'Unknown Title';
              final authors = (volumeInfo['authors'] as List<dynamic>?)?.join(', ') ?? 'Unknown Author';
              final imageUrl =
                  volumeInfo['imageLinks']?['thumbnail'] ??
                      volumeInfo['imageLinks']?['smallThumbnail'] ??
                      '';
              final pageCount = volumeInfo['pageCount'] ?? 0;

              nameController.text = '$name by $authors';
              imageUrlController.text = imageUrl;
              totalPagesController.text = pageCount.toString();
              setState(() {
                // Clear search results after selection
                searchResults.clear();
              });
              // Remove focus from the search field
              FocusScope.of(context).unfocus();
            }

            return Container(
              height: sheetHeight,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sheetHeader,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Search bar
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  labelText: 'Search for a book',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onSubmitted: (_) => _searchBooks(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: isSearching
                                  ? const CircularProgressIndicator()
                                  : const Icon(Icons.search),
                              onPressed: _searchBooks,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  // Search results list
                  if (searchResults.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final item = searchResults[index];
                          final volumeInfo = item['volumeInfo'] ?? {};
                          final title = volumeInfo['title'] ?? 'Unknown Title';
                          final authors = (volumeInfo['authors'] as List<dynamic>?)?.join(', ') ?? 'Unknown Author';
                          final imageUrl = volumeInfo['imageLinks']?['smallThumbnail'] ?? '';

                          return ListTile(
                            leading: imageUrl.isNotEmpty
                                ? Image.network(imageUrl,
                                width: 40,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.book, size: 40))
                                : const Icon(Icons.book),
                            title: Text(title),
                            subtitle: Text(authors),
                            onTap: () => _selectBookFromSearch(item),
                          );
                        },
                      ),
                    ),
                  // Manual form, only shown if there are no search results
                  if (searchResults.isEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('OR'),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // The button is now always at the bottom, outside the conditional blocks.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ElevatedButton.icon(
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
                  ),
                ],
              ),
            );
          },
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
