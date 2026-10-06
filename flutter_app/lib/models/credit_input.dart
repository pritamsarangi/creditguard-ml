class CreditInput {
  final double creditLimit;
  final int age;
  final int recentPaymentStatus;
  final int previousPaymentStatus;
  final double currentBillAmount;
  final double previousBillAmount;
  final double latestPaymentAmount;
  final double previousPaymentAmount;

  const CreditInput({
    required this.creditLimit,
    required this.age,
    required this.recentPaymentStatus,
    required this.previousPaymentStatus,
    required this.currentBillAmount,
    required this.previousBillAmount,
    required this.latestPaymentAmount,
    required this.previousPaymentAmount,
  });

  Map<String, dynamic> toJson() => {
        'credit_limit': creditLimit,
        'age': age,
        'recent_payment_status': recentPaymentStatus,
        'previous_payment_status': previousPaymentStatus,
        'current_bill_amount': currentBillAmount,
        'previous_bill_amount': previousBillAmount,
        'latest_payment_amount': latestPaymentAmount,
        'previous_payment_amount': previousPaymentAmount,
      };

  factory CreditInput.demo() => const CreditInput(
        creditLimit: 120000,
        age: 32,
        recentPaymentStatus: 0,
        previousPaymentStatus: 0,
        currentBillAmount: 90000,
        previousBillAmount: 85000,
        latestPaymentAmount: 5000,
        previousPaymentAmount: 5000,
      );
}
