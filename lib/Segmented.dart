import 'package:flutter/material.dart';

class Segmented extends StatelessWidget {
  const Segmented({
    required this.current,
    required this.onChanged,
    required this.items,
  });
  final int current;
  final ValueChanged<int> onChanged;
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  height: 36,

                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: i == current
                        ? const Color.fromARGB(26, 255, 255, 255)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i].$1, size: 18),
                      const SizedBox(width: 6),
                      Text(items[i].$2, style: theme.textTheme.labelLarge),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
