import 'package:cloud_firestore/cloud_firestore.dart';

class ReadingLog {
  final String bookName;
  final int pages;
  final DateTime timestamp;
  final String? id;

  ReadingLog({
    required this.bookName,
    required this.pages,
    required this.timestamp,
    this.id,
  });

  factory ReadingLog.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, [SnapshotOptions? options]) {
    final data = snapshot.data()!;
    return ReadingLog(
      id: snapshot.id,
      bookName: data['bookName'],
      pages: data['pages'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookName': bookName,
      'pages': pages,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
