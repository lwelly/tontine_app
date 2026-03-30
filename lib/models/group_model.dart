class TontineGroup {
  final String id;
  final String name;
  final int monthlyAmount;
  final int duration;

  TontineGroup({
    required this.id,
    required this.name,
    required this.monthlyAmount,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'monthlyAmount': monthlyAmount,
      'duration': duration,
      'createdAt': DateTime.now(),
    };
  }
}
