import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wizalog_your_reading_habit/models/book.dart';
import 'package:wizalog_your_reading_habit/models/book_status.dart';

class WishlistTab extends StatelessWidget {
  const WishlistTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Book>('books').listenable(),
      builder: (context, box, _) {
        final wishlistBooks = box.values.where((b) => b.status == BookStatus.wishlist).toList();
        if (wishlistBooks.isEmpty) {
          return const Center(child: Text('Your wishlist is empty. Add a book!'));
        }

        return ListView.builder(
          itemCount: wishlistBooks.length,
          itemBuilder: (context, index) {
            final book = wishlistBooks[index];
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
                    const Icon(Icons.bookmark_border, size: 50),
                  ),
                )
                    : const Icon(Icons.bookmark_border, size: 50),
                title: Text(book.name),
                trailing: IconButton(
                  icon: const Icon(Icons.local_library),
                  onPressed: () => _moveToActive(context, book),
                ),
                onLongPress: () => _showDeleteBookDialog(context, book),
              ),
            );
          },
        );
      },
    );
  }

  void _moveToActive(BuildContext context, Book book) async {
    book.status = BookStatus.active;
    await book.save();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book.name} moved to Active Books.')),
    );
  }

  void _showDeleteBookDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete from Wishlist'),
        content: Text('Are you sure you want to delete "${book.name}" from your wishlist?'),
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
    } catch (e) {
      print('Error deleting book: $e');
    }
  }
}
