import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final ValueChanged<Color?> onColorChanged;
  final Color selectedColor;

  const ColorPicker({
    Key? key,
    required this.onColorChanged,
    required this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildColorCircle(Colors.red),
        _buildColorCircle(Colors.green),
        _buildColorCircle(Colors.blue),
      ],
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () => onColorChanged(color),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
