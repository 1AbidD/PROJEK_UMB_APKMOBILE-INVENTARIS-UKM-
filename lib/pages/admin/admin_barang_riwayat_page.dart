import 'package:flutter/material.dart';
import 'package:inventaris_ukm/db/database_helper.dart';

class AdminBarangRiwayatPage extends StatefulWidget {
  final int barangId;
  final String barangNama;

  const AdminBarangRiwayatPage({
    super.key,
    required this.barangId,
    required this.barangNama,
  });

  @override
  State<AdminBarangRiwayatPage> createState() => _AdminBarangRiwayatPageState();
}

class _AdminBarangRiwayatPageState extends State<AdminBarangRiwayatPage> {
  bool loading = true;
  List<Map<String, dynamic>> riwayat = [];

  @override
  void initState() {
    super.initState();
    loadRiwayat();
  }

  // ================================================================
  // LOAD RIWAYAT BARANG
  // ================================================================
  Future<void> loadRiwayat() async {
    final data =
        await DatabaseHelper.instance.getRiwayatByBarang(widget.barangId);

    setState(() {
      riwayat = data;
      loading = false;
    });
  }

  // ================================================================
  // FORMAT TANGGAL (SELALU YYYY-MM-DD)
  // ================================================================
  String formatDate(String? t) {
    if (t == null) return "-";
    final s = t.toString();
    if (s.length >= 10) return s.substring(0, 10);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat - ${widget.barangNama}"),
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
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: riwayat.length,
                  itemBuilder: (context, index) {
                    final r = riwayat[index];

                    final username = r['username'] ?? "-";
                    final userId = r['user_id'] ?? "-";
                    final formattedUser = "$username ($userId)";

                    final statusRaw =
                        (r['status'] ?? "").toString().toLowerCase();
                    final bool isKembali = statusRaw == "kembali";
                    final bool isPinjam = statusRaw == "pinjam";

                    final tanggal = formatDate(r['tanggal']);

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // JUDUL
                            Text(
                              isKembali
                                  ? "Dikembalikan oleh : $formattedUser"
                                  : "Dipinjam oleh : $formattedUser",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // TANGGAL
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isKembali
                                      ? "Tanggal Pengembalian:"
                                      : "Tanggal Peminjaman:",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(tanggal),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // STATUS
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Status:",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  isKembali
                                      ? "Kembali"
                                      : (isPinjam ? "Pinjam" : "-"),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isKembali ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
