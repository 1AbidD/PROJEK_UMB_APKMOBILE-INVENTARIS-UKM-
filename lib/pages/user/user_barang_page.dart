import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventaris_ukm/db/database_helper.dart';
import 'package:inventaris_ukm/models/user.dart';
import 'user_barang_detail_page.dart';

class UserBarangPage extends StatefulWidget {
  final User user;

  const UserBarangPage({super.key, required this.user});

  @override
  State<UserBarangPage> createState() => _UserBarangPageState();
}

class _UserBarangPageState extends State<UserBarangPage> {
  List<Map<String, dynamic>> barangList = [];
  bool loading = true;

  String searchKeyword = "";
  String selectedFilter = "all";

  int total = 0;
  int available = 0;
  int borrowed = 0;

  @override
  void initState() {
    super.initState();
    loadData();
    loadAnalysis();
  }

  // ======================================================
  // LOAD DATA BARANG
  // ======================================================
  Future<void> loadData() async {
    setState(() => loading = true);

    List<Map<String, dynamic>> data = [];

    if (searchKeyword.isNotEmpty) {
      data = await DatabaseHelper.instance.searchBarang(searchKeyword);
    } else if (selectedFilter == "available") {
      data = await DatabaseHelper.instance.getBarangByStatus("available");
    } else if (selectedFilter == "borrowed") {
      data = await DatabaseHelper.instance.getBarangByStatus("borrowed");
    } else {
      data = await DatabaseHelper.instance.getAllBarang();
    }

    setState(() {
      barangList = data;
      loading = false;
    });
  }

  // ======================================================
  // LOAD ANALISIS
  // ======================================================
  Future<void> loadAnalysis() async {
    final data = await DatabaseHelper.instance.getBarangAnalysis();
    setState(() {
      total = data['total']!;
      available = data['available']!;
      borrowed = data['borrowed']!;
    });
  }

  // ======================================================
  // POPUP PEMINJAMAN
  // ======================================================
  Future<void> showPinjamPopup(Map<String, dynamic> barang) async {
    DateTime? tanggalPinjam;
    DateTime? tanggalKembali;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              "Konfirmasi Peminjaman",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nama User : ${widget.user.username}"),
                Text("User ID   : ${widget.user.id}"),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tanggal Pinjam:"),
                    IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 60)),
                          initialDate: now,
                        );
                        if (picked != null) {
                          setState(() {
                            tanggalPinjam = picked;
                            tanggalKembali = picked.add(const Duration(days: 14));
                          });
                        }
                      },
                    ),
                  ],
                ),

                if (tanggalPinjam != null)
                  Text(
                    "➡ ${tanggalPinjam!.toIso8601String().substring(0, 10)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                const SizedBox(height: 10),
                const Text("Tanggal Kembali (otomatis):"),
                if (tanggalKembali != null)
                  Text(
                    "➡ ${tanggalKembali!.toIso8601String().substring(0, 10)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                child: const Text("Request"),
                onPressed: tanggalPinjam == null
                    ? null
                    : () async {
                        await DatabaseHelper.instance.insertPeminjaman({
                          'user_id': widget.user.id,
                          'barang_id': barang['id'],
                          'tanggal_pinjam': tanggalPinjam.toString(),
                          'tanggal_balik': tanggalKembali.toString(),
                          'status': 'pending',
                          'approved_by': null,
                          'approved_at': null,
                        });

                    

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Permintaan peminjaman '${barang['nama']}' dikirim",
                            ),
                          ),
                        );
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  // ======================================================
  // BADGE STATUS
  // ======================================================
  Widget statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == "available" ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == "available" ? "Tersedia" : "Dipinjam",
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  // ======================================================
  // FILTER BUTTON UI
  // ======================================================
  Widget filterButton(String label, String value) {
    final bool active = selectedFilter == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFilter = value;
            searchKeyword = "";
          });
          loadData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.blue : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // MAIN UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Barang"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              searchKeyword = "";
              selectedFilter = "all";
              loadData();
              loadAnalysis();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari nama / kode barang...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                searchKeyword = val.trim();
                loadData();
              },
            ),
          ),

          const SizedBox(height: 10),

          // FILTER BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                filterButton("Semua", "all"),
                const SizedBox(width: 8),
                filterButton("Tersedia", "available"),
                const SizedBox(width: 8),
                filterButton("Dipinjam", "borrowed"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ANALISIS BOX
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _analysisBox("Total", total, Colors.blue),
                    _analysisBox("Tersedia", available, Colors.green),
                    _analysisBox("Dipinjam", borrowed, Colors.red),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // LIST BARANG USER
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : barangList.isEmpty
                    ? const Center(child: Text("Tidak ada barang"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: barangList.length,
                        itemBuilder: (_, i) {
                          final b = barangList[i];
                          final status = b['status'] ?? 'available';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // FOTO BARANG
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: (b['image_url'] != null &&
                                            b['image_url'].toString().isNotEmpty)
                                        ? Image.file(
                                            File(b['image_url']),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 30,
                                            ),
                                          ),
                                  ),

                                  const SizedBox(width: 12),

                                  // INFO BARANG
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b['nama'] ?? '-',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text("Kode: ${b['kode']}"),
                                        Text("Kondisi: ${b['kondisi']}"),

                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            statusBadge(status),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.info_outline,
                                                    color: Colors.blue,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => UserBarangDetailPage(
                                                          barang: b,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                ElevatedButton(
                                                  onPressed: status == 'borrowed'
                                                      ? null
                                                      : () => showPinjamPopup(b),
                                                  child: const Text(
                                                    "Pinjam",
                                                    style: TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // ANALYSIS BOX UI
  // ======================================================
  Widget _analysisBox(String title, int count, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(
          "$count",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
