// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collectible_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectibleAdapter extends TypeAdapter<Collectible> {
  @override
  final int typeId = 1;

  @override
  Collectible read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Collectible(
      tokenAddress: fields[0] as String,
      name: fields[1] as String,
      tokenId: fields[2] as String,
      description: fields[4] as String?,
      imageUrl: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Collectible obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.tokenAddress)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.tokenId)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectibleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
