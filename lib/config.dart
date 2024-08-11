import 'package:flutter_dotenv/flutter_dotenv.dart';

final appName = dotenv.env['APP_NAME'] ?? "";
// const baseUrl = "http://127.0.0.1:3001";
final baseUrl = dotenv.env['API_BASE_URL'] ?? "";

// WALLET_CONNECT_SETUP
final projectId = dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? "";
