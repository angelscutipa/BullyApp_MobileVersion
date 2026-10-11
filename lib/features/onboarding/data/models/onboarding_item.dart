import 'package:flutter/material.dart';

class OnboardingFeature {
  final IconData icon;
  final String title;

  const OnboardingFeature({
    required this.icon,
    required this.title,
  });
}

class OnboardingItem {
  final String badgeText;
  final String titlePrefix;
  final String highlightedText;
  final String titleSuffix;
  final List<OnboardingFeature> features;
  final Widget centerWidget;
  final List<String>? tags; // Tags adicionales al lado derecho de las features (ej: WEB3, GLOBAL)
  final String? footerLockText; // Texto inferior opcional con icono de candado

  const OnboardingItem({
    required this.badgeText,
    required this.titlePrefix,
    required this.highlightedText,
    this.titleSuffix = '',
    required this.features,
    required this.centerWidget,
    this.tags,
    this.footerLockText,
  });
}

