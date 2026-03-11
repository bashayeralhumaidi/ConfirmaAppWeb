import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String apiBase = String.fromEnvironment(
	'API_URL',
	defaultValue: 'https://confirmaapplication-bxfba9gybnhyfvcy.westeurope-01.azurewebsites.net',
);

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

String globalUserName = "";
