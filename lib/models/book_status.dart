import 'package:hive/hive.dart';

part 'book_status.g.dart';

@HiveType(typeId: 0)
enum BookStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  wishlist,
}