import 'package:flutter/material.dart';

// AUTH
import 'package:inventaris_ukm/pages/auth/login_page.dart';
import 'package:inventaris_ukm/pages/auth/register_page.dart';

// MODEL
import 'package:inventaris_ukm/models/user.dart';

// ADMIN PAGES
import 'package:inventaris_ukm/pages/admin/admin_dashboard_page.dart';
import 'package:inventaris_ukm/pages/admin/admin_barang_page.dart';
import 'package:inventaris_ukm/pages/admin/admin_peminjaman_pending_page.dart';
import 'package:inventaris_ukm/pages/admin/admin_pengembalian_pending_page.dart';

// USER PAGES
import 'package:inventaris_ukm/pages/user/user_home_page.dart';
import 'package:inventaris_ukm/pages/user/user_barang_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Inventaris UKM",
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),

      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),

        '/admin-dashboard': (ctx) =>
            const _MissingUserPage("AdminDashboardPage membutuhkan User"),

        '/admin-barang': (ctx) =>
            const _MissingUserPage("AdminBarangPage membutuhkan User"),

        '/admin-peminjaman-pending': (ctx) =>
            const _MissingUserPage("AdminPeminjamanPending membutuhkan User"),

        '/admin-pengembalian-pending': (ctx) =>
            const _MissingUserPage("AdminPengembalianPending membutuhkan User"),

        '/user-home': (ctx) =>
            const _MissingUserPage("UserHomePage membutuhkan User"),

        '/user-barang': (ctx) =>
            const _MissingUserPage("UserBarangPage membutuhkan User"),
      },
    );
  }
}

class _MissingUserPage extends StatelessWidget {
  final String message;
  const _MissingUserPage(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parameter Hilang")),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }
}
