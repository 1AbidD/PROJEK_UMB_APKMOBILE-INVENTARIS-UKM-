import 'package:flutter/material.dart';
import 'package:inventaris_ukm/models/user.dart';
import 'package:inventaris_ukm/db/database_helper.dart';
import 'package:intl/intl.dart';

class UserRiwayatPage extends StatefulWidget {
  final User user;

  const UserRiwayatPage({super.key, required this.user});

  @override
  State<UserRiwayatPage> createState() => _UserRiwayatPageState();
}

class _UserRiwayatPageState extends State<UserRiwayatPage> {
  List<Map<String, dynamic>> riwayat = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRiwayat();
  }

  Future<void> loadRiwayat() async {
    setState(() => loading = true);

    final db = await DatabaseHelper.instance.db;

    final result = await db.rawQuery('''
      SELECT p.id, p.tanggal_pinjam, p.status, p.approved_at,
             b.nama AS barang_nama
      FROM peminjaman p
      JOIN barang b ON p.barang_id = b.id
      WHERE p.user_id = ?
      ORDER BY p.id DESC
    ''', [widget.user.id]);

    setState(() {
      riwayat = result;
      loading = false;
    });
  }

  String formatDate(String? iso) {
    if (iso == null) return "-";
    return DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(iso));
  }

  Color statusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "returned":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Peminjaman"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : riwayat.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada riwayat peminjaman",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadRiwayat,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: riwayat.length,
                    itemBuilder: (_, i) {
                      final r = riwayat[i];

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            r['barang_nama'] ?? "Barang",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "Tanggal Pinjam : ${formatDate(r['tanggal_pinjam'])}\n"
                            "Tanggal Approve : ${formatDate(r['approved_at'])}",
                          ),
                          trailing: Chip(
                            label: Text(
                              r['status'].toString().toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                statusColor(r['status'] ?? "pending"),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
