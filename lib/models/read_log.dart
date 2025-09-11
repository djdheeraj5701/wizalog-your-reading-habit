import 'package:hive/hive.dart';

part 'read_log.g.dart';

@HiveType(typeId: 2)
class ReadLog extends HiveObject {
  @HiveField(0)
  late String bookId;

  @HiveField(1)
  late int pagesRead;

  @HiveField(2)
  late DateTime timestamp;
}