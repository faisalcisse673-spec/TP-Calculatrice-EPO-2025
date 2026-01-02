import 'package:flutter/material.dart';

/// Bouton personnalisé réutilisable pour la calculatrice.
///
/// Ce widget encapsule l'apparence et le comportement d'un bouton
/// de calculatrice selon la maquette demandée :
/// - Forme rectangulaire aux bords très arrondis
/// - Hauteur fixe pour un aspect uniforme
/// - Gestion du tap via [GestureDetector]
/// - Flexible (peut s'étendre horizontalement si [isWide] = true)
///
/// Tous les boutons de l'interface utilisent ce composant,
/// garantissant une cohérence visuelle et comportementale.
class CalcButton extends StatelessWidget {
  /// Texte affiché au centre du bouton.
  ///
  /// Peut être un chiffre ('0'-'9'), un opérateur ('+', '-', '×', '÷'),
  /// ou une fonction spéciale ('C', '%', '+/-', '.', '=').
  final String label;

  /// Couleur de fond du bouton.
  ///
  /// Doit respecter la charte graphique de la maquette :
  /// - Gris foncé (#333333) pour les chiffres
  /// - Gris clair (#A5A5A5) pour 'C', '+/-', '%'
  /// - Orange (#FF9500) pour les opérateurs et '='
  final Color color;

  /// Couleur du texte affiché sur le bouton.
  ///
  /// Selon la maquette :
  /// - Blanc pour la plupart des boutons
  /// - Noir pour 'C', '+/-', '%' (sur fond gris clair)
  final Color textColor;

  /// Fonction de rappel appelée lorsque l'utilisateur appuie sur le bouton.
  ///
  /// Cette fonction est typiquement reliée à [CalculatorLogic.handleInput]
  /// pour traiter l'entrée correspondante.
  final VoidCallback onTap;

  /// Contrôle la largeur du bouton dans une [Row].
  ///
  /// Si `true`, le bouton occupe 2 unités de flex ([flex] = 2)
  /// au lieu d'1. Utilisé pour le bouton '0' dans certaines dispositions.
  /// (Note : Dans la disposition finale, ce paramètre n'est pas utilisé
  /// car le bouton '0' n'est pas large, mais il est conservé pour
  /// la réutilisabilité du composant.)
  final bool isWide;

  /// Construit un bouton de calculatrice configurable.
  ///
  /// @param key      Clé optionnelle pour le widget
  /// @param label    Texte du bouton (requis)
  /// @param color    Couleur de fond (requise)
  /// @param textColor Couleur du texte (requise)
  /// @param onTap    Fonction au tap (requise)
  /// @param isWide   Étendue horizontale (défaut: false)
  const CalcButton({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // Contrôle la proportion horizontale dans une Row
      // Si isWide = true, prend 2 fois plus d'espace
      flex: isWide ? 2 : 1,
      child: Padding(
        // Marge interne entre les boutons
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          // Détecte le tap et appelle la fonction onTap
          onTap: onTap,
          child: Container(
            // Hauteur fixe pour garantir un aspect carré/rectangulaire uniforme
            // indépendamment du contenu
            height: 80,
            decoration: BoxDecoration(
              color: color,
              // Bords très arrondis (valeur 40 donne un effet "pilule")
              // Cette valeur a été choisie pour correspondre à l'esthétique
              // des calculatrices mobiles modernes
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 32, // Taille lisible sur mobile
                  fontWeight: FontWeight.w400, // Poids normal
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}