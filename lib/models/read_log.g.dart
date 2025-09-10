// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'read_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadLogAdapter extends TypeAdapter<ReadLog> {
  @override
  final int typeId = 2;

  @override
  ReadLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadLog()
      ..bookId = fields[0] as String
      ..pagesRead = fields[1] as int
      ..timestamp = fields[2] as DateTime;
  }

  @override
  void write(BinaryWriter writer, ReadLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.bookId)
      ..writeByte(1)
      ..write(obj.pagesRead)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
