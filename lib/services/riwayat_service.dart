import 'package:inventaris_ukm/db/database_helper.dart';
import 'package:inventaris_ukm/models/riwayat.dart';

class RiwayatService {
  RiwayatService._();
  static final RiwayatService instance = RiwayatService._();

  Future<void> logEvent({
    required int userId,
    required int barangId,
    required String status, 
  }) async {
    final db = await DatabaseHelper.instance.db;
    final now = DateTime.now().toIso8601String();

    await db.insert('riwayat', {
      'user_id': userId,
      'barang_id': barangId,
      'tanggal': now,
      'status': status,
    });
  }

  Future<List<Riwayat>> getRiwayatByBarang(int barangId) async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query(
      'riwayat',
      where: 'barang_id = ?',
      whereArgs: [barangId],
      orderBy: 'tanggal DESC',
    );
    return res.map((e) => Riwayat.fromMap(e)).toList();
  }

  Future<List<Riwayat>> getRiwayatByUser(int userId) async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query(
      'riwayat',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'tanggal DESC',
    );
    return res.map((e) => Riwayat.fromMap(e)).toList();
  }
}
