import 'package:flutter/material.dart';

class NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final String? prefixText;
  final bool decimal;
  final double? min;
  final double? max;

  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    this.prefixText,
    this.decimal = true,
    this.min,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimal,
        signed: false,
      ),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixText: prefixText,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }

        final parsed = double.tryParse(value.trim());
        if (parsed == null) {
          return 'Enter a valid number';
        }

        if (min != null && parsed < min!) {
          return 'Minimum ${_format(min!)}';
        }

        if (max != null && parsed > max!) {
          return 'Maximum ${_format(max!)}';
        }

        return null;
      },
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
