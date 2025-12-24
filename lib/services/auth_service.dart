import 'package:inventaris_ukm/db/database_helper.dart';
import 'package:inventaris_ukm/models/user.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  // =====================================================
  // LOGIN
  // =====================================================
  Future<User?> login(String username, String password) async {
    final data = await DatabaseHelper.instance.login(username, password);

    if (data == null) return null;

    return User.fromMap(data);
  }

  // =====================================================
  // REGISTER 
  // =====================================================
  Future<String?> register(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return "Username atau password kosong";
    }

    try {
      final db = DatabaseHelper.instance;

      await db.db.then((database) {
        database.insert('users', {
          'username': username,
          'password': password,
          'role': 'user',
          'approved': 1, // langsung aktif
          'created_at': DateTime.now().toIso8601String(),
        });
      });

      return null; // sukses
    } catch (e) {
      if (e.toString().contains("UNIQUE")) {
        return "Username sudah digunakan";
      }

      return "Terjadi kesalahan: $e";
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================
  Future<void> logout() async {
    // Tidak perlu clear database karena tidak ada session
    // Cukup return saja, logout ditangani navigator
    return;
  }
}
