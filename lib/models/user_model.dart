class AppUser {
  final String uid;
  final String name;
  final String phone;
  final String? email;

  AppUser({
    required this.uid,
    required this.name,
    required this.phone,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'createdAt': DateTime.now(),
    };
  }
}
