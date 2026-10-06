import 'package:flutter/material.dart';

class PaymentStatusOption {
  final int value;
  final String label;

  const PaymentStatusOption(this.value, this.label);
}

const paymentStatusOptions = <PaymentStatusOption>[
  PaymentStatusOption(-2, 'No recent payment activity'),
  PaymentStatusOption(-1, 'Paid as agreed'),
  PaymentStatusOption(0, 'Current / no recorded delay'),
  PaymentStatusOption(1, '1 month late'),
  PaymentStatusOption(2, '2 months late'),
  PaymentStatusOption(3, '3 months late'),
  PaymentStatusOption(4, '4 months late'),
  PaymentStatusOption(5, '5 months late'),
  PaymentStatusOption(6, '6 months late'),
  PaymentStatusOption(7, '7 months late'),
  PaymentStatusOption(8, '8 months late'),
  PaymentStatusOption(9, '9+ months late'),
];

class StatusDropdown extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int?> onChanged;

  const StatusDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        helperText: 'Choose the closest repayment status',
      ),
      items: paymentStatusOptions
          .map(
            (option) => DropdownMenuItem<int>(
              value: option.value,
              child: Text(
                option.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
