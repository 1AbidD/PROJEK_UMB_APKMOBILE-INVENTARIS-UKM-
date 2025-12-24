import 'package:flutter/material.dart';
import 'package:inventaris_ukm/db/database_helper.dart';
import 'package:inventaris_ukm/models/user.dart';

class AdminPengembalianPendingPage extends StatefulWidget {
  final User admin;

  const AdminPengembalianPendingPage({super.key, required this.admin});

  @override
  State<AdminPengembalianPendingPage> createState() =>
      _AdminPengembalianPendingPageState();
}

class _AdminPengembalianPendingPageState
    extends State<AdminPengembalianPendingPage> {
  List<Map<String, dynamic>> list = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ============================================================
  // LOAD DATA (JOIN BARANG)
  // ============================================================
  Future<void> loadData() async {
    setState(() => loading = true);

    final pending = await DatabaseHelper.instance.getPendingPengembalian();
    List<Map<String, dynamic>> finalList = [];

    for (var p in pending) {
      final barang =
          await DatabaseHelper.instance.getBarangById(p['barang_id']);

      finalList.add({
        ...p,
        'barang_nama': barang?['nama'] ?? '-',
        'barang_kode': barang?['kode'] ?? '-',
        'barang_kondisi': barang?['kondisi'] ?? '-',
        'barang_deskripsi': barang?['deskripsi'] ?? '-',
      });
    }

    setState(() {
      list = finalList;
      loading = false;
    });
  }

  // ============================================================
  // POPUP KONFIRMASI PENGEMBALIAN
  // ============================================================
  Future<void> _showConfirmPopup(Map<String, dynamic> p) async {
    final TextEditingController kondisiC =
        TextEditingController(text: p['barang_kondisi']);
    final TextEditingController deskripsiC =
        TextEditingController(text: p['barang_deskripsi']);

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Konfirmasi Pengembalian"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Barang : ${p['barang_nama']}"),
                Text("Kode   : ${p['barang_kode']}"),
                const SizedBox(height: 12),

                const Text("Kondisi Baru"),
                TextField(
                  controller: kondisiC,
                  decoration: const InputDecoration(
                    hintText: "Contoh: Bagus, Rusak, Pecah...",
                  ),
                ),

                const SizedBox(height: 12),

                const Text("Deskripsi Baru"),
                TextField(
                  controller: deskripsiC,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Deskripsi kondisi terkini barang",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () async {
                Navigator.pop(context);
                await _processReturn(
                  p,
                  kondisiC.text.trim(),
                  deskripsiC.text.trim(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PROSES PENGEMBALIAN
  // ============================================================
  Future<void> _processReturn(
      Map<String, dynamic> p, String kondisiBaru, String deskripsiBaru) async {
    final int peminjamanId = p['id'];
    final int barangId = p['barang_id'];
    final int userId = p['user_id'];

    //  UPDATE BARANG
    await DatabaseHelper.instance.updateBarang(barangId, {
      'kondisi': kondisiBaru,
      'deskripsi': deskripsiBaru,
      'status': 'available',
    });

    //  INSERT ke tabel pengembalian 
    await DatabaseHelper.instance.insertPengembalian({
      'peminjaman_id': peminjamanId,
      'tanggal_kembali': DateTime.now().toIso8601String(),
      'kondisi_baru': kondisiBaru,
    });

    // UPDATE status peminjaman → returned
    await DatabaseHelper.instance.setPeminjamanReturned(peminjamanId);

    // MASUKKAN KE RIWAYAT
    await DatabaseHelper.instance.insertRiwayatKembali(userId, barangId);

    // FEEDBACK
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text("Pengembalian barang '${p['barang_nama']}' telah diproses")),
    );

    loadData();
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengembalian Pending"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? const Center(
                  child: Text("Tidak ada pengembalian pending"),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final p = list[i];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['barang_nama'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text("User ID    : ${p['user_id']}"),
                            Text("Barang ID  : ${p['barang_id']}"),
                            Text("Kondisi    : ${p['barang_kondisi']}"),
                            Text("Deskripsi  : ${p['barang_deskripsi']}"),

                            const SizedBox(height: 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green, size: 28),
                                onPressed: () => _showConfirmPopup(p),
                              ),
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
