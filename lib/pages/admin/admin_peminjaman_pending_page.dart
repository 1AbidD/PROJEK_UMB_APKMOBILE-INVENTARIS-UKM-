import 'package:flutter/material.dart';
import 'package:inventaris_ukm/db/database_helper.dart';
import 'package:inventaris_ukm/models/user.dart';

class AdminPeminjamanPendingPage extends StatefulWidget {
  final User admin;

  const AdminPeminjamanPendingPage({super.key, required this.admin});

  @override
  State<AdminPeminjamanPendingPage> createState() =>
      _AdminPeminjamanPendingPageState();
}

class _AdminPeminjamanPendingPageState
    extends State<AdminPeminjamanPendingPage> {
  bool loading = true;
  List<Map<String, dynamic>> list = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // =============================================================
  // LOAD DATA PEMINJAMAN PENDING
  // =============================================================
  Future<void> loadData() async {
    setState(() => loading = true);

    final db = await DatabaseHelper.instance.db;

    final data = await db.rawQuery("""
      SELECT p.id, p.user_id, p.barang_id,
             p.tanggal_pinjam, p.tanggal_balik,
             u.username AS peminjam_nama,
             b.nama AS barang_nama, b.kondisi AS barang_kondisi
      FROM peminjaman p
      LEFT JOIN users u ON u.id = p.user_id
      LEFT JOIN barang b ON b.id = p.barang_id
      WHERE p.status = 'pending'
      ORDER BY p.id DESC
    """);

    setState(() {
      list = data;
      loading = false;
    });
  }

  // =============================================================
  // APPROVE PEMINJAMAN
  // =============================================================
  Future<void> approve(int id) async {
    await DatabaseHelper.instance.approvePeminjaman(id, widget.admin.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Peminjaman disetujui")),
    );

    loadData();
  }

  // =============================================================
  // REJECT PEMINJAMAN
  // =============================================================
  Future<void> reject(int id) async {
    await DatabaseHelper.instance.deletePeminjaman(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Peminjaman ditolak")),
    );

    loadData();
  }

  // =============================================================
  // FORMAT TANGGAL (YYYY-MM-DD) 
  // =============================================================
  String formatDate(String? input) {
    if (input == null || input.isEmpty) return "-";
    final dt = DateTime.tryParse(input);
    if (dt == null) return input;

    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  // =============================================================
  // UI
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Peminjaman Pending")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? const Center(child: Text("Tidak ada peminjaman pending"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final p = list[i];

                    final namaBarang = p['barang_nama'] ?? "Barang Tidak Dikenal";
                    final kondisi = p['barang_kondisi'] ?? "-";
                    final peminjamNama = p['peminjam_nama'] ?? "Tidak Diketahui";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaBarang,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text("Peminjam : $peminjamNama (ID: ${p['user_id']})"),
                            Text("ID Barang : ${p['barang_id']}"),
                            Text("Kondisi : $kondisi"),
                            Text("Tgl Pinjam : ${formatDate(p['tanggal_pinjam'])}"),
                            Text("Tgl Kembali : ${formatDate(p['tanggal_balik'])}"),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => approve(p['id']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => reject(p['id']),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
