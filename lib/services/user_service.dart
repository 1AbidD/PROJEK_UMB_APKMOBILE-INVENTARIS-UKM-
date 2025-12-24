import 'package:inventaris_ukm/db/database_helper.dart';
import 'package:inventaris_ukm/models/user.dart';
import 'package:inventaris_ukm/models/user_detail.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  Future<List<User>> getAllUsers() async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query('users', orderBy: 'created_at DESC');
    return res.map((e) => User.fromMap(e)).toList();
  }

  Future<List<User>> getPendingUsers() async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query(
      'users',
      where: 'approved = 0 AND role = ?',
      whereArgs: ['user'],
      orderBy: 'created_at DESC',
    );
    return res.map((e) => User.fromMap(e)).toList();
  }

  Future<int> approveUser(int userId) async {
    final db = await DatabaseHelper.instance.db;
    return db.update(
      'users',
      {
        'approved': 1,
        'created_at': DateTime.now().toIso8601String(), // optional
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUser(int userId) async {
    final db = await DatabaseHelper.instance.db;
    // hapus detail juga
    await db.delete('user_details', where: 'user_id = ?', whereArgs: [userId]);
    return db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<User?> getUserById(int id) async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }

  Future<UserDetail?> getUserDetailByUserId(int userId) async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query(
      'user_details',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return UserDetail.fromMap(res.first);
  }

  Future<int> updateUserDetail(UserDetail detail) async {
    final db = await DatabaseHelper.instance.db;
    return db.update(
      'user_details',
      detail.toMap(),
      where: 'id = ?',
      whereArgs: [detail.id],
    );
  }
}
