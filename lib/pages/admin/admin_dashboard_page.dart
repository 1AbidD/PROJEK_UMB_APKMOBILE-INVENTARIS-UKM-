import 'package:flutter/material.dart';
import 'package:inventaris_ukm/models/user.dart';


import 'package:inventaris_ukm/pages/admin/admin_barang_page.dart';
import 'package:inventaris_ukm/pages/admin/admin_barang_form_page.dart';
import 'package:inventaris_ukm/pages/admin/admin_peminjaman_pending_page.dart';
import 'package:inventaris_ukm/pages/admin/admin_pengembalian_pending_page.dart';

class AdminDashboardPage extends StatelessWidget {
  final User admin;

  const AdminDashboardPage({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Admin (${admin.username})"),
  
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),

          // ==== HEADER ADMIN ====
          Text(
            "Selamat datang, ${admin.username}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // ======================================================
          // MENU UTAMA
          // ======================================================

          _menuButton(
            context,
            icon: Icons.inventory,
            title: "Kelola Barang",
            subtitle: "Tambah, Edit, & Hapus Barang",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminBarangPage()),
              );
            },
          ),

          _menuButton(
            context,
            icon: Icons.add_box,
            title: "Tambah Barang Baru",
            subtitle: "Masukkan barang baru ke daftar inventaris",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminBarangFormPage()),
              );
            },
          ),

          _menuButton(
            context,
            icon: Icons.pending_actions,
            title: "Peminjaman Pending",
            subtitle: "Lihat & setujui permintaan peminjaman",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminPeminjamanPendingPage(admin: admin),
                ),
              );
            },
          ),

          _menuButton(
            context,
            icon: Icons.assignment_return,
            title: "Pengembalian Pending",
            subtitle: "Konfirmasi barang yang dikembalikan",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminPengembalianPendingPage(admin: admin),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          const Divider(height: 1),
          const SizedBox(height: 10),

          // ======================================================
          // LOGOUT — TOMBOL UTAMA
          // ======================================================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  // =================================================================
  // WIDGET KARTU MENU
  // =================================================================
  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
