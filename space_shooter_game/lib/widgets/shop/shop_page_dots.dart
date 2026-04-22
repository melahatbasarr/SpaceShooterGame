import 'package:flutter/material.dart';

class ShopPageDots extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const ShopPageDots({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) {
          final bool isActive = index == currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF3A7BFF)
                  : Colors.white24,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}