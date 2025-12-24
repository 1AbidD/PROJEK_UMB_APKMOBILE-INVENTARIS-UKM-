class UserDetail {
  final int? id;
  final int userId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? createdAt;

  UserDetail({
    this.id,
    required this.userId,
    this.fullName,
    this.email,
    this.phone,
    this.createdAt,
  });

  factory UserDetail.fromMap(Map<String, dynamic> map) {
    return UserDetail(
      id: map['id'],
      userId: map['user_id'],
      fullName: map['full_name'],
      email: map['email'],
      phone: map['phone'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'created_at': createdAt,
    };
  }
}
