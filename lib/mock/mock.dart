import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet_cryptomask/core/create_wallet_provider/create_wallet_provider.dart';
import 'package:hive/hive.dart';

class MockCreateWalletProvider extends Mock implements CreateWalletProvider {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockBox extends Mock implements Box {}
