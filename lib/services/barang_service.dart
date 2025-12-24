import 'package:inventaris_ukm/db/database_helper.dart';
import 'package:inventaris_ukm/models/barang.dart';

class BarangService {
  BarangService._();
  static final BarangService instance = BarangService._();

  Future<List<Barang>> getAllBarang() async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query('barang', orderBy: 'nama ASC');
    return res.map((e) => Barang.fromMap(e)).toList();
  }

  Future<Barang?> getBarangById(int id) async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query('barang', where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return Barang.fromMap(res.first);
  }

  Future<int> insertBarang(Barang barang) async {
    final db = await DatabaseHelper.instance.db;
    return db.insert('barang', barang.toMap());
  }

  Future<int> updateBarang(Barang barang) async {
    final db = await DatabaseHelper.instance.db;
    return db.update(
      'barang',
      barang.toMap(),
      where: 'id = ?',
      whereArgs: [barang.id],
    );
  }

  Future<int> deleteBarang(int id) async {
    final db = await DatabaseHelper.instance.db;
    // jika perlu: hapus peminjaman & riwayat terkait barang ini
    await db.delete('peminjaman', where: 'barang_id = ?', whereArgs: [id]);
    await db.delete('riwayat', where: 'barang_id = ?', whereArgs: [id]);
    return db.delete('barang', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStok(int barangId, int newStok) async {
    final db = await DatabaseHelper.instance.db;
    return db.update(
      'barang',
      {'stok': newStok},
      where: 'id = ?',
      whereArgs: [barangId],
    );
  }
}
