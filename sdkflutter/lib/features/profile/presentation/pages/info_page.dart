import 'package:flutter/material.dart';

/// Écran secondaire du SDK, affiché dans le deuxième onglet Flutter.
class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Future écran informations du SDK Flutter',
        textAlign: TextAlign.center,
      ),
    );
  }
}
