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
                leading: const Icon(Icons.bookmark_border),
                title: Text(book.name),
              ),
            );
          },
        );
      },
    );
  }
}