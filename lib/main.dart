import 'package:flutter/material.dart';
import 'pages/page_calculatrice.dart';

/// Point d'entrée principal de l'application Flutter.
///
/// Ce fichier initialise l'application et configure le thème global
/// selon les exigences du TP : thème sombre, fond noir, police Roboto.
void main() {
  runApp(const MyApp());
}

/// Widget racine de l'application.
///
/// Configure [MaterialApp] avec les paramètres suivants :
/// - Désactive la bannière de debug (`debugShowCheckedModeBanner: false`)
/// - Définit le titre de l'application
/// - Applique un thème sombre avec fond noir et police Roboto
/// - Définit [CalculatorPage] comme écran d'accueil
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculatrice Flutter',
      theme: ThemeData(
        // Thème sombre imposé par le TP (conforme à la maquette noire)
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
      ),
      home: const CalculatorPage(),
    );
  }
}