import 'package:flutter/material.dart';
import '../../models/transportation.dart';

class TransportationSelector extends StatelessWidget {
  final TransportationType selectedType;
  final Function(TransportationType) onTypeChanged;

  const TransportationSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: TransportationType.values.map((type) {
        final isSelected = type == selectedType;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  type.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                onTypeChanged(type);
              }
            },
          ),
        );
      }).toList(),
    );
  }
}