import 'package:flutter/material.dart';
import 'package:inventaris_ukm/db/database_helper.dart';
import 'package:inventaris_ukm/pages/admin/admin_barang_form_page.dart';
import 'package:inventaris_ukm/pages/admin/admin_barang_riwayat_page.dart';

class AdminBarangPage extends StatefulWidget {
  const AdminBarangPage({super.key});

  @override
  State<AdminBarangPage> createState() => _AdminBarangPageState();
}

class _AdminBarangPageState extends State<AdminBarangPage> {
  List<Map<String, dynamic>> barangList = [];
  bool loading = true;

  String searchKeyword = "";
  String selectedFilter = "all"; // all, available, borrowed

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // =====================================================
  // LOAD DATA BARANG
  // =====================================================
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

  // =====================================================
  // DELETE BARANG
  // =====================================================
  Future<void> deleteBarang(int id, String nama) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Barang"),
        content: Text("Yakin ingin menghapus '$nama'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await DatabaseHelper.instance.deleteBarang(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Barang berhasil dihapus")),
      );
    }

    loadData();
  }

  // =====================================================
  // FILTER BUTTON
  // =====================================================
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

  // =====================================================
  // STATUS BADGE
  // =====================================================
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

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Barang"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminBarangFormPage(),
            ),
          );
          if (result == true) loadData();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // SEARCH BAR
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

          // FILTER
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

          // LIST BARANG
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b['nama'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Kode: ${b['kode']}"),
                                  Text("Kondisi: ${b['kondisi']}"),
                                  const SizedBox(height: 10),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      statusBadge(status),

                                      Row(
                                        children: [
                                          // ===========================
                                          // TOMBOL HISTORY (BARU)
                                          // ===========================
                                          IconButton(
                                           icon: const Icon(Icons.history, color: Colors.blueGrey),
                                           onPressed: () {
                                           Navigator.push(
                                           context,
                                           MaterialPageRoute(
                                           builder: (_) => AdminBarangRiwayatPage(
                                             barangId: b['id'],
                                             barangNama: b['nama'],
                                            ),
                                           ),
                                          );
                                         },
                                        ),


                                          // EDIT
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      AdminBarangFormPage(
                                                    barang: b,
                                                  ),
                                                ),
                                              );
                                              if (result == true) loadData();
                                            },
                                          ),

                                          // DELETE
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                deleteBarang(b['id'], b['nama']),
                                          ),
                                        ],
                                      ),
                                    ],
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
}
