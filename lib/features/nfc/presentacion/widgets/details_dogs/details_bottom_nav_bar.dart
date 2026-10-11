import 'package:flutter/material.dart';

class DetailsBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const DetailsBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBgColor = Color(0xFF0F0F12);
    const Color cardBgColor = Color(0xFF1A1A1E);
    const Color accentGold = Color(0xFFFFB800);
    const Color textGrey = Color(0xFF8E8E93);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: scaffoldBgColor,
        border: Border(
          top: BorderSide(
            color: Color(0xFF1E1E24),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Tab 1: Ejemplar
            Expanded(
              child: InkWell(
                onTap: () => onTabSelected(0),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedIndex == 0 ? const Color(0xFF1E170C) : cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedIndex == 0 ? accentGold : const Color(0xFF282832),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets_rounded,
                        color: selectedIndex == 0 ? accentGold : textGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ejemplar',
                        style: TextStyle(
                          color: selectedIndex == 0 ? accentGold : textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Tab 2: Propietario
            Expanded(
              child: InkWell(
                onTap: () => onTabSelected(1),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedIndex == 1 ? const Color(0xFF1E170C) : cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedIndex == 1 ? accentGold : const Color(0xFF282832),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: selectedIndex == 1 ? accentGold : textGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Propietario',
                        style: TextStyle(
                          color: selectedIndex == 1 ? accentGold : textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selectedIndex == 1) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: accentGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
