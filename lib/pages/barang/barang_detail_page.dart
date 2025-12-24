import 'dart:io';

import 'package:flutter/material.dart';

class BarangDetailPage extends StatelessWidget {
  final Map<String, dynamic> barang;

  const BarangDetailPage({super.key, required this.barang});

  Widget statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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

  @override
  Widget build(BuildContext context) {
    final img = barang['image_url'] as String?;
    final status = (barang['status'] as String?) ?? 'available';

    return Scaffold(
      appBar: AppBar(
        title: Text(barang['nama'] ?? 'Detail Barang'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Gambar
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              height: 220,
              alignment: Alignment.center,
              child: img != null &&
                      img.isNotEmpty &&
                      File(img).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(img),
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_outlined,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          "Tidak ada foto",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  barang['nama'] ?? '-',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              statusBadge(status),
            ],
          ),
          const SizedBox(height: 8),
          if (barang['kode'] != null && barang['kode'] != "")
            Text("Kode: ${barang['kode']}"),
          const SizedBox(height: 8),
          Text("Kondisi: ${barang['kondisi'] ?? '-'}"),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            "Deskripsi",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(barang['deskripsi']?.toString().isNotEmpty == true
              ? barang['deskripsi']
              : "-"),
          const SizedBox(height: 16),
          if (barang['created_at'] != null)
            Text(
              "Ditambahkan: ${barang['created_at']}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
