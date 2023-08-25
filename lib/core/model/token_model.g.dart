// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TokenAdapter extends TypeAdapter<Token> {
  @override
  final int typeId = 0;

  @override
  Token read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Token(
      tokenAddress: fields[0] as String,
      symbol: fields[1] as String,
      decimal: fields[2] as int,
      balance: fields[3] as double,
      balanceInFiat: fields[4] as double,
      imageUrl: fields[5] as String?,
      coinGeckoID: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Token obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.tokenAddress)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.decimal)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.balanceInFiat)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.coinGeckoID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
