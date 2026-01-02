/// Gestion de la logique métier (business logic) de la calculatrice.
///
/// Cette classe est le "cœur" de l'application. Elle :
/// 1. Stocke l'état interne (nombres, opérateur, affichages)
/// 2. Implémente les algorithmes de calcul
/// 3. Traite les interactions utilisateur via [handleInput]
/// 4. Formate les résultats pour l'affichage
///
/// L'interface utilisateur ([CalculatorPage]) se contente d'afficher
/// les propriétés [display] et [currentOperation] et de transmettre
/// les entrées utilisateur. Cette séparation respecte le pattern MVC.
class CalculatorLogic {
  /// Valeur affichée en grand texte (zone résultat).
  /// Initialisée à '0' comme toute calculatrice au démarrage.
  String _display = '0';

  /// Opération en cours affichée en petit texte (zone supérieure).
  /// Format : "195.0 × 4789.0 =" (exemple du sujet)
  String _currentOperation = '';

  /// Premier nombre stocké pour un calcul binaire (opérateur à 2 opérandes).
  /// Null si aucun nombre n'a été stocké (début ou après 'C').
  double? _firstNumber;

  /// Deuxième nombre stocké pour le calcul.
  double? _secondNumber;

  /// Opérateur mathématique en cours ('+', '-', '×', '÷').
  /// Null si aucun opérateur n'a été sélectionné.
  String? _operator;

  /// Drapeau indiquant si l'affichage doit être réinitialisé à la prochaine saisie.
  ///
  /// Mis à `true` après :
  /// - Un appui sur un opérateur (pour saisir le second nombre)
  /// - Un calcul (pour saisir un nouveau premier nombre)
  /// - Une opération unaire (%, +/-)
  ///
  /// Permet de distinguer "ajouter un chiffre" de "remplacer l'affichage".
  bool _shouldResetDisplay = false;

  /// Getter public pour l'affichage principal (grand texte).
  ///
  /// @return La valeur actuelle formatée pour l'affichage
  String get display => _display;

  /// Getter public pour l'opération en cours (petit texte).
  ///
  /// @return L'expression mathématique en cours de construction
  String get currentOperation => _currentOperation;

  /// Point d'entrée principal : traite l'appui sur n'importe quel bouton.
  ///
  /// Cette méthode joue le rôle de "routeur" : elle analyse [buttonText]
  /// et appelle la méthode privée appropriée.
  ///
  /// @param buttonText Le texte du bouton pressé ('C', '5', '+', '=', etc.)
  void handleInput(String buttonText) {
    if (buttonText == 'C') {
      _clearAll();
    } else if (buttonText == '+/-') {
      _toggleSign();
    } else if (buttonText == '%') {
      _applyPercentage();
    } else if (buttonText == '.') {
      _addDecimal();
    } else if (_isOperator(buttonText)) {
      _setOperator(buttonText);
    } else if (buttonText == '=') {
      _calculateResult();
    } else {
      // Bouton numérique (0-9)
      _inputNumber(buttonText);
    }
  }

  /// ==================== MÉTHODES PRIVÉES ====================

  /// Réinitialise complètement la calculatrice à son état initial.
  ///
  /// Appelée par le bouton 'C' (Clear). Remet tous les champs
  /// à leurs valeurs par défaut comme une calculatrice physique.
  void _clearAll() {
    _display = '0';
    _currentOperation = '';
    _firstNumber = null;
    _secondNumber = null;
    _operator = null;
    _shouldResetDisplay = false;
  }

  /// Bascule le signe du nombre actuellement affiché (positif/négatif).
  ///
  /// Exemple : "5" → "-5" → "5"
  /// Ne fait rien si l'affichage vaut '0'.
  void _toggleSign() {
    if (_display != '0') {
      if (_display.startsWith('-')) {
        _display = _display.substring(1); // Retire le '-'
      } else {
        _display = '-$_display'; // Ajoute le '-'
      }
    }
  }

  /// Applique une opération de pourcentage au nombre affiché.
  ///
  /// CHOIX D'IMPLÉMENTATION POUR LE BOUTON % :
  /// Le sujet demandait de "préciser dans le code" l'implémentation
  /// (modulo ou pourcentage). Nous avons choisi le POURCENTAGE car :
  /// 1. C'est l'opération la plus courante sur les calculatrices mobiles
  /// 2. Elle est intuitive pour l'utilisateur (division par 100)
  /// 3. Elle correspond aux attentes pédagogiques d'une calculatrice simple
  ///
  /// Implémentation : divise le nombre courant par 100.
  /// Exemple : "50" → "0.5", "200" → "2"
  void _applyPercentage() {
    final double value = double.tryParse(_display) ?? 0;
    final double result = value / 100;
    _display = _formatNumber(result);
    _shouldResetDisplay = true; // Prêt pour une nouvelle saisie
  }

  /// Ajoute une virgule décimale au nombre affiché.
  ///
  /// Vérifie d'abord qu'il n'y a pas déjà un point décimal
  /// (évite les nombres comme "5.3.1").
  /// Exemple : "5" → "5."
  void _addDecimal() {
    if (!_display.contains('.')) {
      _display = '$_display.';
    }
  }

  /// Vérifie si un texte correspond à un opérateur binaire supporté.
  ///
  /// @param text Le texte à vérifier
  /// @return `true` si c'est un opérateur ('+', '-', '×', '÷')
  bool _isOperator(String text) {
    return ['+', '-', '×', '÷'].contains(text);
  }

  /// Définit l'opérateur pour le prochain calcul.
  ///
  /// Gère aussi l'enchaînement des calculs : si un opérateur était déjà
  /// défini, calcule d'abord le résultat avant de le remplacer.
  ///
  /// @param newOperator Le nouvel opérateur ('+', '-', '×', '÷')
  void _setOperator(String newOperator) {
    // Enchaînement : 5 + 3 × 2 calcule d'abord 5+3=8, puis 8×2
    if (_operator != null && !_shouldResetDisplay) {
      _calculateResult();
    }

    _firstNumber = double.tryParse(_display);
    _operator = newOperator;
    // Met à jour l'affichage secondaire : "5 +"
    _currentOperation = '${_formatNumber(_firstNumber!)} $_operator';
    _shouldResetDisplay = true; // Prêt à saisir le second nombre
  }

  /// Traite la saisie d'un chiffre (0-9).
  ///
  /// Deux modes :
  /// 1. Mode "remplacement" (_shouldResetDisplay = true) : le chiffre remplace l'affichage
  /// 2. Mode "concaténation" (sinon) : le chiffre s'ajoute à droite
  ///
  /// @param digit Le chiffre saisi ('0' à '9')
  void _inputNumber(String digit) {
    if (_shouldResetDisplay || _display == '0') {
      _display = digit; // Remplace (ex: après un opérateur)
      _shouldResetDisplay = false;
    } else {
      _display += digit; // Concatène (ex: "5" → "53")
    }
  }

  /// Effectue le calcul avec les nombres et l'opérateur stockés.
  ///
  /// 1. Vérifie qu'on a bien les deux nombres et un opérateur
  /// 2. Exécute l'opération correspondante
  /// 3. Gère les cas spéciaux (division par zéro)
  /// 4. Met à jour les affichages et l'état interne
  void _calculateResult() {
    // Conditions minimales pour un calcul
    if (_firstNumber == null || _operator == null) return;

    _secondNumber = double.tryParse(_display);
    if (_secondNumber == null) return;

    double result;
    switch (_operator) {
      case '+':
        result = _firstNumber! + _secondNumber!;
        break;
      case '-':
        result = _firstNumber! - _secondNumber!;
        break;
      case '×':
        result = _firstNumber! * _secondNumber!;
        break;
      case '÷':
      // Gestion d'erreur : division par zéro
        if (_secondNumber == 0) {
          _display = 'Erreur';
          _currentOperation = '';
          _firstNumber = null;
          _operator = null;
          _shouldResetDisplay = true;
          return;
        }
        result = _firstNumber! / _secondNumber!;
        break;
      default:
        return; // Ne devrait jamais arriver
    }

    // Mise à jour de l'affichage principal
    _display = _formatNumber(result);

    // Mise à jour de l'affichage secondaire : "5 + 3 ="
    _currentOperation = '${_formatNumber(_firstNumber!)} $_operator ${_formatNumber(_secondNumber!)} =';

    // Permet l'enchaînement : le résultat devient le premier nombre
    // pour l'opération suivante (ex: 5+3=8, puis ×2=16)
    _firstNumber = result;
    _shouldResetDisplay = true; // Prêt pour une nouvelle saisie
  }

  /// Formate un nombre [double] pour l'affichage.
  ///
  /// Objectifs :
  /// 1. Supprimer les ".0" inutiles (5.0 → 5)
  /// 2. Limiter la précision à 8 chiffres significatifs
  /// 3. Éviter la notation scientifique
  ///
  /// @param number Le nombre à formater
  /// @return Une chaîne adaptée à l'affichage
  String _formatNumber(double number) {
    // Si c'est un entier (5.0, 12.0, etc.)
    if (number % 1 == 0) {
      return number.toInt().toString();
    } else {
      // Pour les nombres à virgule :
      // 1. toStringAsPrecision(8) : limite à 8 chiffres significatifs
      // 2. replaceAll(RegExp(r'0*$'), '') : supprime les zéros finaux
      // 3. replaceAll(RegExp(r'\.$'), '') : supprime le point si seul
      // Exemple : 3.1400000 → "3.14"
      return number.toStringAsPrecision(8)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }
}