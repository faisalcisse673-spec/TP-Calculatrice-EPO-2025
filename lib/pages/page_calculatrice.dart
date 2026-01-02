import 'package:flutter/material.dart';
import '../widgets/bouton_calcul.dart';
import '../utils/logique_calcul.dart';

/// Page principale de la calculatrice.
///
/// Ce widget Stateful gère l'interface utilisateur complète de l'application.
/// Il affiche :
/// 1. Une zone d'affichage pour l'opération en cours et le résultat
/// 2. Un clavier tactile avec tous les boutons de la calculatrice
///
/// La logique métier est déléguée à une instance de [CalculatorLogic].
/// L'interface est mise à jour via [setState] lors de chaque interaction.
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

/// État de la page de calculatrice.
///
/// Gère :
/// - L'instance de la logique métier ([_logic])
/// - La reconstruction de l'UI lors des interactions
/// - La construction des boutons avec les styles demandés
class _CalculatorPageState extends State<CalculatorPage> {
  /// Instance de la logique métier qui gère les calculs et l'état interne.
  /// Utilisée pour récupérer les valeurs d'affichage et traiter les entrées.
  final CalculatorLogic _logic = CalculatorLogic();

  /// Gère l'appui sur un bouton du clavier.
  ///
  /// Transmet l'entrée à [CalculatorLogic.handleInput] puis déclenche
  /// une mise à jour de l'interface via [setState].
  ///
  /// @param buttonText Le texte du bouton pressé (ex: '5', '+', 'C')
  void _onButtonPressed(String buttonText) {
    setState(() {
      _logic.handleInput(buttonText);
    });
  }

  /// Construit un bouton de la calculatrice avec les propriétés visuelles demandées.
  ///
  /// Cette méthode factory simplifie la création des boutons en appliquant
  /// les couleurs par défaut de la maquette (gris foncé #333333, texte blanc).
  ///
  /// @param text      Le label du bouton
  /// @param color     Couleur de fond (optionnelle, gris par défaut)
  /// @param textColor Couleur du texte (optionnelle, blanc par défaut)
  /// @param isWide    Si vrai, le bouton s'étend horizontalement (non utilisé ici)
  /// @return Un widget [CalcButton] configuré
  Widget _buildButton(
      String text, {
        Color? color,
        Color? textColor,
        bool isWide = false,
      }) {
    // Définition des couleurs selon la maquette
    final Color btnColor = color ?? const Color(0xFF333333); // Gris foncé par défaut
    final Color txtColor = textColor ?? Colors.white;

    return CalcButton(
      label: text,
      color: btnColor,
      textColor: txtColor,
      onTap: () => _onButtonPressed(text),
      isWide: isWide,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fond noir imposé par la maquette
      body: SafeArea(
        child: Column(
          children: [
            // ============ ZONE D'AFFICHAGE (HAUT) ============
            // Prend 1/3 de l'espace vertical (flex:1 sur un total de 3)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Affichage de l'opération en cours (petit texte gris)
                    // Format: "195.0 × 4789.0 =" (exemple du sujet)
                    Text(
                      _logic.currentOperation,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 8),
                    // Affichage du résultat (grand texte blanc)
                    // Format: "933855" (exemple du sujet)
                    Text(
                      _logic.display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Tronque si trop long
                    ),
                  ],
                ),
              ),
            ),

            // ============ CLAVIER (BAS) ============
            // Prend 2/3 de l'espace vertical (flex:2 sur un total de 3)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Première ligne : C, %, ÷, ×
                    // Note: Le bouton '+/-' a été déplacé à la dernière ligne
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('C'),
                          _buildButton('%'),
                          _buildButton('÷', color: const Color(0xFFFF9500)),
                          _buildButton('×', color: const Color(0xFFFF9500)),
                        ],
                      ),
                    ),
                    // Deuxième ligne : 7, 8, 9, -
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('7'),
                          _buildButton('8'),
                          _buildButton('9'),
                          _buildButton('-', color: const Color(0xFFFF9500)),
                        ],
                      ),
                    ),
                    // Troisième ligne : 4, 5, 6, +
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('4'),
                          _buildButton('5'),
                          _buildButton('6'),
                          _buildButton('+', color: const Color(0xFFFF9500)),
                        ],
                      ),
                    ),
                    // Quatrième et Cinquième lignes COMBINÉES
                    // Le bouton '=' prend la hauteur de 2 lignes (flex:2)
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Colonne gauche (3/4 de largeur) : 6 boutons sur 2 lignes
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                // Première sous-ligne : 1, 2, 3
                                Expanded(
                                  child: Row(
                                    children: [
                                      _buildButton('1'),
                                      _buildButton('2'),
                                      _buildButton('3'),
                                    ],
                                  ),
                                ),
                                // Deuxième sous-ligne : +/-, 0, .
                                Expanded(
                                  child: Row(
                                    children: [
                                      _buildButton('+/-'),
                                      _buildButton('0'),
                                      _buildButton('.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Colonne droite (1/4 de largeur) : bouton '=' sur 2 lignes
                          Expanded(
                            child: _buildButton('=', color: const Color(0xFFFF9500)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}