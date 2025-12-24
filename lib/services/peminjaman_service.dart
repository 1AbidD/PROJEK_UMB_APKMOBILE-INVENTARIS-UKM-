import 'package:inventaris_ukm/db/database_helper.dart';
import 'package:inventaris_ukm/models/peminjaman.dart';
import 'package:inventaris_ukm/models/pengembalian.dart';
import 'package:inventaris_ukm/services/barang_service.dart';
import 'package:inventaris_ukm/services/riwayat_service.dart';

class PeminjamanService {
  PeminjamanService._();
  static final PeminjamanService instance = PeminjamanService._();

  /// User request pinjam barang
  Future<int> requestPeminjaman({
    required int userId,
    required int barangId,
  }) async {
    final db = await DatabaseHelper.instance.db;
    final now = DateTime.now().toIso8601String();

    final peminjamanId = await db.insert('peminjaman', {
      'user_id': userId,
      'barang_id': barangId,
      'tanggal_pinjam': now,
      'status': 'pending',
      'approved_by': null,
      'approved_at': null,
    });

    // catat riwayat 
    await RiwayatService.instance.logEvent(
      userId: userId,
      barangId: barangId,
      status: 'pinjam-pending',
    );

    return peminjamanId;
  }

  /// Admin approve
  Future<void> approvePeminjaman({
    required int peminjamanId,
    required int adminId,
  }) async {
    final db = await DatabaseHelper.instance.db;

    final now = DateTime.now().toIso8601String();

    // ambil data peminjaman untuk tau user & barang
    final res = await db.query(
      'peminjaman',
      where: 'id = ?',
      whereArgs: [peminjamanId],
      limit: 1,
    );
    if (res.isEmpty) return;
    final map = res.first;
    final userId = map['user_id'] as int;
    final barangId = map['barang_id'] as int;

    await db.update(
      'peminjaman',
      {
        'status': 'approved',
        'approved_by': adminId,
        'approved_at': now,
      },
      where: 'id = ?',
      whereArgs: [peminjamanId],
    );


    final barang = await BarangService.instance.getBarangById(barangId);
    if (barang != null) {
      final newStok = (barang.stok - 1).clamp(0, 999999);
      await BarangService.instance.updateStok(barangId, newStok);
    }

    // catat riwayat
    await RiwayatService.instance.logEvent(
      userId: userId,
      barangId: barangId,
      status: 'pinjam',
    );
  }

  /// Proses pengembalian barang
  Future<void> kembalikanBarang({
    required int peminjamanId,
    String? catatan,
    String? kondisiBaru,
  }) async {
    final db = await DatabaseHelper.instance.db;

    final now = DateTime.now().toIso8601String();

    final res = await db.query(
      'peminjaman',
      where: 'id = ?',
      whereArgs: [peminjamanId],
      limit: 1,
    );
    if (res.isEmpty) return;
    final map = res.first;
    final userId = map['user_id'] as int;
    final barangId = map['barang_id'] as int;

    // insert ke pengembalian
    await db.insert('pengembalian', {
      'peminjaman_id': peminjamanId,
      'tanggal_kembali': now,
      'catatan': catatan,
      'kondisi_baru': kondisiBaru,
    });

    // update peminjaman -> returned
    await db.update(
      'peminjaman',
      {
        'status': 'returned',
      },
      where: 'id = ?',
      whereArgs: [peminjamanId],
    );

    final barang = await BarangService.instance.getBarangById(barangId);
    if (barang != null) {
      final newStok = barang.stok + 1;
      await BarangService.instance.updateStok(barangId, newStok);
    }

    // catat riwayat
    await RiwayatService.instance.logEvent(
      userId: userId,
      barangId: barangId,
      status: 'kembali',
    );
  }

  Future<List<Peminjaman>> getPeminjamanByUser(int userId) async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query(
      'peminjaman',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'tanggal_pinjam DESC',
    );
    return res.map((e) => Peminjaman.fromMap(e)).toList();
  }

  Future<List<Peminjaman>> getAllPending() async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query(
      'peminjaman',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'tanggal_pinjam DESC',
    );
    return res.map((e) => Peminjaman.fromMap(e)).toList();
  }
}
