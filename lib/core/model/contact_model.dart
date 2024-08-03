import 'package:hive/hive.dart';
part 'contact_model.g.dart';

@HiveType(typeId: 5)
class Contact {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String address;
  @HiveField(2)
  final String networkId;
  @HiveField(3)
  final String id;

  Contact({required this.name, required this.address, required this.networkId, required this.id});
}
