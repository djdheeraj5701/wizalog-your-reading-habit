import 'package:hive/hive.dart';
import 'book_status.dart';

part 'book.g.dart';

@HiveType(typeId: 1)
class Book extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String imageUrl;

  @HiveField(2)
  late BookStatus status;

  @HiveField(3)
  late int totalPages;

  @HiveField(4)
  late int totalPagesRead;
}