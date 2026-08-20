import 'package:flutter/material.dart';

class TagBtn extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool active;

  const TagBtn(this.text, this.active, this.icon, {super.key});

  @override
  State<TagBtn> createState() => _TagBtnState();
}

class _TagBtnState extends State<TagBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = _isHovered || widget.active;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.amber : Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: isActive ? Colors.black : Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                widget.text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.black : Colors.white,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}