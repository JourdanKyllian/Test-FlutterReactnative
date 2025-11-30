import 'package:flutter/material.dart';
import 'azeoo_sdk.dart';

/// Entrypoint embarqué pour les applis hôtes (RN, Android natif, iOS natif).
///
/// Ce main sera appelé par une FlutterActivity / FlutterViewController.
/// Les valeurs de test sont en dur.
void main() {
  const baseUrl = 'https://api.azeoo.dev/v1';
  const token =
      'api_474758da8532e795f63bc4e5e6beca7298379993f65bb861f2e8e13c352cc4dcebcc3b10961a5c369edb05fbc0b0053cf63df1c53d9ddd7e4e5d680beb514d20';
  const userId = '3';

  final sdk = AzeooSdk(
    baseUrl: baseUrl,
    token: token,
  );

  runApp(
    sdk.buildProfileRoot(userId: userId),
  );
}
