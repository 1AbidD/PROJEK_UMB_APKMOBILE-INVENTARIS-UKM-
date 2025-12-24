
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  // ===============================================================
  // GET DATABASE INSTANCE
  // ===============================================================
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // ===============================================================
  // INIT DATABASE
  // ===============================================================
  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, "inventaris_ukm.db");

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ===============================================================
  // CREATE TABLE 
  // ===============================================================
  Future<void> _onCreate(Database db, int version) async {
    // USERS
    await db.execute("""
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        approved INTEGER DEFAULT 1,
        created_at TEXT
      );
    """);

    // BARANG
    await db.execute("""
      CREATE TABLE barang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        kode TEXT UNIQUE,
        kondisi TEXT,
        status TEXT DEFAULT 'available',
        image_url TEXT,
        deskripsi TEXT,
        created_at TEXT
      );
    """);

    // PEMINJAMAN
    await db.execute("""
      CREATE TABLE peminjaman (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        barang_id INTEGER NOT NULL,
        tanggal_pinjam TEXT NOT NULL,
        tanggal_balik TEXT,
        status TEXT,
        approved_by INTEGER,
        approved_at TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(barang_id) REFERENCES barang(id)
      );
    """);

    // PENGEMBALIAN (tanpa catatan)
    await db.execute("""
      CREATE TABLE pengembalian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        peminjaman_id INTEGER NOT NULL,
        tanggal_kembali TEXT,
        kondisi_baru TEXT,
        deskripsi_baru TEXT,
        FOREIGN KEY(peminjaman_id) REFERENCES peminjaman(id)
      );
    """);

    // RIWAYAT PINJAM / KEMBALI
    await db.execute("""
      CREATE TABLE riwayat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        barang_id INTEGER NOT NULL,
        tanggal TEXT,
        status TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(barang_id) REFERENCES barang(id)
      );
    """);

    // DEFAULT USER ADMIN & USER BIASA
    await db.insert("users", {
      "username": "admin",
      "password": "admin",
      "role": "admin",
      "approved": 1,
      "created_at": DateTime.now().toIso8601String(),
    });

    await db.insert("users", {
      "username": "user",
      "password": "user",
      "role": "user",
      "approved": 1,
      "created_at": DateTime.now().toIso8601String(),
    });
  }

  // ===============================================================
  Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE peminjaman ADD COLUMN tanggal_balik TEXT;",
      );
    }

    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE barang ADD COLUMN image_url TEXT;",
      );
    }
  }

  // ===============================================================
  // AUTH / LOGIN & USER
  // ===============================================================

  Future<Map<String, dynamic>?> login(
      String username, String password) async {
    final database = await db;
    final res = await database.query(
      "users",
      where: "username = ? AND password = ? AND approved = 1",
      whereArgs: [username, password],
      limit: 1,
    );
    return res.isEmpty ? null : res.first;
  }

  // Optional: digunakan jika kamu punya halaman Data User
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return (await db)
        .query("users", orderBy: "id ASC");
  }

  Future<int> insertUser(Map<String, dynamic> data) async {
    return (await db).insert("users", data);
  }

  Future<int> updateUser(int id, Map<String, dynamic> data) async {
    return (await db).update(
      "users",
      data,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    return (await db).delete(
      "users",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    return (await db).query(
      "users",
      where: "approved = 0",
      orderBy: "id ASC",
    );
  }

  Future<int> approveUser(int id) async {
    return (await db).update(
      "users",
      {"approved": 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // ===============================================================
  // CRUD BARANG
  // ===============================================================

  Future<int> insertBarang(Map<String, dynamic> data) async {
    return (await db).insert("barang", data);
  }

  Future<int> updateBarang(int id, Map<String, dynamic> data) async {
    return (await db).update(
      "barang",
      data,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteBarang(int id) async {
    return (await db).delete(
      "barang",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getBarangById(int id) async {
    final res = await (await db).query(
      "barang",
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    return res.isEmpty ? null : res.first;
  }

  Future<List<Map<String, dynamic>>> getAllBarang() async {
    return (await db).query(
      "barang",
      orderBy: "nama ASC",
    );
  }

  Future<bool> isKodeBarangExists(String kode) async {
    final res = await (await db).query(
      "barang",
      where: "kode = ?",
      whereArgs: [kode],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getBarangByStatus(
      String status) async {
    return (await db).query(
      "barang",
      where: "status = ?",
      whereArgs: [status],
      orderBy: "nama ASC",
    );
  }

  Future<List<Map<String, dynamic>>> searchBarang(
      String keyword) async {
    return (await db).query(
      "barang",
      where: "nama LIKE ? OR kode LIKE ?",
      whereArgs: ["%$keyword%", "%$keyword%"],
      orderBy: "nama ASC",
    );
  }

  // ===============================================================
  // ANALISIS BARANG (DASHBOARD)
  // ===============================================================

  Future<Map<String, int>> getBarangAnalysis() async {
    final database = await db;

    final total = Sqflite.firstIntValue(
          await database.rawQuery(
              "SELECT COUNT(*) FROM barang"),
        ) ??
        0;

    final available = Sqflite.firstIntValue(
          await database.rawQuery(
              "SELECT COUNT(*) FROM barang WHERE status='available'"),
        ) ??
        0;

    final borrowed = Sqflite.firstIntValue(
          await database.rawQuery(
              "SELECT COUNT(*) FROM barang WHERE status='borrowed'"),
        ) ??
        0;

    return {
      "total": total,
      "available": available,
      "borrowed": borrowed,
    };
  }

  // ===============================================================
  // PEMINJAMAN
  // ===============================================================

  Future<int> insertPeminjaman(Map<String, dynamic> data) async {
    return (await db).insert("peminjaman", data);
  }

  Future<List<Map<String, dynamic>>> getPendingPeminjaman() async {
    return (await db).query(
      "peminjaman",
      where: "status = 'pending'",
      orderBy: "tanggal_pinjam DESC",
    );
  }

  Future<int> deletePeminjaman(int id) async {
    return (await db).delete(
      "peminjaman",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// Dipanggil oleh admin saat APPROVE peminjaman.
  /// - Update barang → borrowed
  /// - Update peminjaman → approved
  /// - Insert ke riwayat dengan status "pinjam"
  Future<int> approvePeminjaman(int id, int adminId) async {
    final database = await db;

    // Ambil data peminjaman
    final peminjaman = await database.query(
      "peminjaman",
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );

    if (peminjaman.isEmpty) return 0;

    final p = peminjaman.first;

    final int userId = p['user_id'] as int;
    final int barangId = p['barang_id'] as int;
    final String tanggalPinjam =
        (p['tanggal_pinjam'] ?? "").toString();

    // Update barang → borrowed
    await database.update(
      "barang",
      {"status": "borrowed"},
      where: "id = ?",
      whereArgs: [barangId],
    );

    // Update peminjaman → approved
    await database.update(
      "peminjaman",
      {
        "status": "approved",
        "approved_by": adminId,
        "approved_at": DateTime.now().toIso8601String(),
      },
      where: "id = ?",
      whereArgs: [id],
    );

    // Insert riwayat PINJAM (1x saja, tidak double)
    await insertRiwayatPinjam(
      userId,
      barangId,
      tanggalPinjam,
    );

    return 1;
  }

  // ===============================================================
  // PENGEMBALIAN
  // ===============================================================

  /// Dipakai AdminPengembalianPendingPage:
  /// ambil semua peminjaman dengan status 'approved'
  Future<List<Map<String, dynamic>>> getPendingPengembalian() async {
    return (await db).query(
      "peminjaman",
      where: "status = 'approved'",
      orderBy: "tanggal_pinjam DESC",
    );
  }

  Future<int> insertPengembalian(Map<String, dynamic> data) async {
    return (await db).insert("pengembalian", data);
  }

  /// Set peminjaman sudah dikembalikan + update status barang → available
  Future<int> setPeminjamanReturned(int id) async {
    final database = await db;

    // Update barang → available
    await database.update(
      "barang",
      {"status": "available"},
      where: "id = (SELECT barang_id FROM peminjaman WHERE id = ?)",
      whereArgs: [id],
    );

    // Update peminjaman → returned
    return await database.update(
      "peminjaman",
      {"status": "returned"},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// Dipanggil saat admin memproses pengembalian
  Future<int> insertRiwayatKembali(int userId, int barangId) async {
    return (await db).insert(
      "riwayat",
      {
        "user_id": userId,
        "barang_id": barangId,
        "tanggal": DateTime.now().toIso8601String(),
        "status": "kembali",
      },
    );
  }

  // ===============================================================
  // RIWAYAT PINJAM / KEMBALI
  // ===============================================================

  /// Dipanggil:
  /// - Saat user mengirim request peminjaman (tanggal dari dialog)
  /// - Atau dari approvePeminjaman (pakai tanggal di tabel peminjaman)
  Future<int> insertRiwayatPinjam(
      int userId, int barangId, String tanggal) async {
    return (await db).insert(
      "riwayat",
      {
        "user_id": userId,
        "barang_id": barangId,
        "tanggal": tanggal,
        "status": "pinjam",
      },
    );
  }

  /// Digunakan di:
  /// - AdminBarangRiwayatPage
  /// - UserBarangDetailPage
  /// username sudah ikut (JOIN ke users)
  Future<List<Map<String, dynamic>>> getRiwayatByBarang(
      int barangId) async {
    final database = await db;

    return await database.rawQuery(
      """
      SELECT r.*, u.username
      FROM riwayat r
      LEFT JOIN users u ON u.id = r.user_id
      WHERE r.barang_id = ?
      ORDER BY r.id DESC
      """,
      [barangId],
    );
  }
}
