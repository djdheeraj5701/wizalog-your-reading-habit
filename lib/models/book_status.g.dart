// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookStatusAdapter extends TypeAdapter<BookStatus> {
  @override
  final int typeId = 0;

  @override
  BookStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BookStatus.active;
      case 1:
        return BookStatus.completed;
      case 2:
        return BookStatus.wishlist;
      default:
        return BookStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, BookStatus obj) {
    switch (obj) {
      case BookStatus.active:
        writer.writeByte(0);
        break;
      case BookStatus.completed:
        writer.writeByte(1);
        break;
      case BookStatus.wishlist:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
