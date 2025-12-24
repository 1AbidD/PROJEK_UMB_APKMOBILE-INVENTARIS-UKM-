class User {
  final int? id;
  final String username;
  final String password;
  final String role; // 'admin' atau 'user'
  final int approved; // 0 pending, 1 active
  final String? createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    this.approved = 0,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      approved: map['approved'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'approved': approved,
      'created_at': createdAt,
    };
  }
}
