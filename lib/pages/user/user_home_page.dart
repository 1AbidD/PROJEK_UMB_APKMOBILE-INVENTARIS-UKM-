import 'package:flutter/material.dart';
import 'package:inventaris_ukm/models/user.dart';

import 'user_barang_page.dart';
import 'user_riwayat_page.dart';
import 'user_profile_page.dart';

class UserHomePage extends StatelessWidget {
  final User user;

  const UserHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventaris UKM - ${user.username}"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),

          // ===================== PROFILE HEADER =========================
          Center(
            child: Text(
              "Halo, ${user.username}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ===================== DAFTAR BARANG ==========================
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text("Daftar Barang"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserBarangPage(user: user),
                ),
              );
            },
          ),

          // ===================== RIWAYAT PEMINJAMAN ======================
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Riwayat Peminjaman"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserRiwayatPage(user: user),
                ),
              );
            },
          ),

          // ============================ PROFILE ==========================
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profil Saya"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfilePage(user: user),
                ),
              );
            },
          ),

          const Divider(height: 40),

          // ============================= LOGOUT ==========================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
