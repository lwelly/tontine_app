class Payment {
  final String groupId;
  final String userId;
  final String month;
  final int amount;

  Payment({
    required this.groupId,
    required this.userId,
    required this.month,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'userId': userId,
      'month': month,
      'amount': amount,
      'paidAt': DateTime.now(),
    };
  }
}
