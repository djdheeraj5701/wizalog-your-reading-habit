import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wizalog_your_reading_habit/models/reading_log.dart';
import 'package:intl/intl.dart';

final readingLogsStreamProvider = StreamProvider<List<ReadingLog>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return const Stream.empty();
  }

  final collectionRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('reading_logs');

  return collectionRef.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => ReadingLog.fromFirestore(doc)).toList();
  });
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsyncValue = ref.watch(readingLogsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History'),
      ),
      body: logsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(
              child: Text(
                'No reading logs found yet!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  title: Text(
                    log.bookName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${log.pages} pages on ${DateFormat('MMMM d, y').format(log.timestamp)} at ${DateFormat('HH:mm').format(log.timestamp)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.menu_book,
                    color: Color(0xFFF3A712),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
