import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventaris_ukm/db/database_helper.dart';

class UserBarangDetailPage extends StatefulWidget {
  final Map<String, dynamic> barang;

  const UserBarangDetailPage({super.key, required this.barang});

  @override
  State<UserBarangDetailPage> createState() => _UserBarangDetailPageState();
}

class _UserBarangDetailPageState extends State<UserBarangDetailPage> {
  List<Map<String, dynamic>> riwayat = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRiwayat();
  }

  Future<void> loadRiwayat() async {
    final data =
        await DatabaseHelper.instance.getRiwayatByBarang(widget.barang['id']);
    setState(() {
      riwayat = data;
      loading = false;
    });
  }

  // Card Riwayat User
  Widget buildRiwayatCard(Map<String, dynamic> item) {
    bool dipinjam = item['status'] == "pinjam";
    String tanggal = item['tanggal']?.toString().substring(0, 10) ?? "-";

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dipinjam
                  ? "Dipinjam oleh : ${item['username']}"
                  : "Dikembalikan oleh : ${item['username']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dipinjam
                    ? "Tanggal Peminjaman:"
                    : "Tanggal Pengembalian:"),
                Text(tanggal,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status:"),
                Text(
                  dipinjam ? "Pinjam" : "Kembali",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dipinjam ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final b = widget.barang;

    return Scaffold(
      appBar: AppBar(title: Text("Riwayat - ${b['nama']}")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Foto barang
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: (b['image_url'] != null &&
                          b['image_url'].toString().isNotEmpty &&
                          File(b['image_url']).existsSync())
                      ? Image.file(
                          File(b['image_url']),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.image_not_supported, size: 60),
                        ),
                ),
                const SizedBox(height: 20),

                Text(
                  b['nama'] ?? "-",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                detailRow("Kode Barang", b['kode']),
                detailRow("Kondisi", b['kondisi']),
                detailRow("Status", b['status']),

                const SizedBox(height: 10),
                const Text("Deskripsi :", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(b['deskripsi'] ?? "-"),

                const SizedBox(height: 25),

                const Text(
                  "Riwayat Peminjaman",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                riwayat.isEmpty
                    ? const Center(child: Text("Belum ada riwayat"))
                    : Column(
                        children:
                            riwayat.map((item) => buildRiwayatCard(item)).toList(),
                      ),
              ],
            ),
    );
  }

  Widget detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text("$label :")),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
