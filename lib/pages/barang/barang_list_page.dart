import 'package:flutter/material.dart';
import 'package:inventaris_ukm/db/database_helper.dart';

class BarangListPage extends StatefulWidget {
  const BarangListPage({super.key});

  @override
  State<BarangListPage> createState() => _BarangListPageState();
}

class _BarangListPageState extends State<BarangListPage> {
  List<Map<String, dynamic>> barangList = [];
  bool loading = true;

  String searchKeyword = "";
  String selectedFilter = "all"; // all, available, borrowed

  int total = 0;
  int available = 0;
  int borrowed = 0;

  @override
  void initState() {
    super.initState();
    loadData();
    loadAnalysis();
  }

  // ============================
  // LOAD DATA BARANG
  // ============================
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

  // ============================
  // ANALISIS BARANG
  // ============================
  Future<void> loadAnalysis() async {
    final data = await DatabaseHelper.instance.getBarangAnalysis();

    setState(() {
      available = data['available']!;
      borrowed = data['borrowed']!;
      total = data['total']!;
    });
  }

  // ============================
  // WIDGET BADGE STATUS
  // ============================
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

  // ============================
  // UI
  // ============================
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

          // ============================
          // SEARCH BAR
          // ============================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari nama barang...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                searchKeyword = value.trim();
                loadData();
              },
            ),
          ),

          const SizedBox(height: 10),

          // ============================
          // FILTER BUTTONS
          // ============================
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

          // ============================
          // ANALISIS RINGKAS
          // ============================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    analysisBox("Total", total, Colors.blue),
                    analysisBox("Tersedia", available, Colors.green),
                    analysisBox("Dipinjam", borrowed, Colors.red),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

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
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Text(
                                b['nama'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Kode: ${b['kode'] ?? '-'}\n"
                                "Kondisi: ${b['kondisi'] ?? '-'}",
                              ),
                              trailing: statusBadge(b['status']),
                              onTap: () {
                                // TODO: Buka detail barang
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ============================
  // FILTER BUTTON WIDGET
  // ============================
  Widget filterButton(String label, String value) {
    final bool active = selectedFilter == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          selectedFilter = value;
          searchKeyword = "";
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

  // ============================
  // ANALYSIS BOX WIDGET
  // ============================
  Widget analysisBox(String title, int count, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(
          "$count",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
