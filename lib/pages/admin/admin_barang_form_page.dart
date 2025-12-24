import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventaris_ukm/db/database_helper.dart';

class AdminBarangFormPage extends StatefulWidget {
  final Map<String, dynamic>? barang; 

  const AdminBarangFormPage({super.key, this.barang});

  @override
  State<AdminBarangFormPage> createState() => _AdminBarangFormPageState();
}

class _AdminBarangFormPageState extends State<AdminBarangFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaC = TextEditingController();
  final _kodeC = TextEditingController();
  final _kondisiC = TextEditingController();
  final _deskripsiC = TextEditingController();

  bool isEdit = false;

  final ImagePicker picker = ImagePicker();
  String? imageUrl; // Path gambar

  @override
  void initState() {
    super.initState();
    isEdit = widget.barang != null;

    if (isEdit) {
      _namaC.text = widget.barang!["nama"] ?? "";
      _kodeC.text = widget.barang!["kode"] ?? "";
      _kondisiC.text = widget.barang!["kondisi"] ?? "";
      _deskripsiC.text = widget.barang!["deskripsi"] ?? "";
      imageUrl = widget.barang!["image_url"];
    }
  }

  @override
  void dispose() {
    _namaC.dispose();
    _kodeC.dispose();
    _kondisiC.dispose();
    _deskripsiC.dispose();
    super.dispose();
  }

  // =====================================================
  // PICK IMAGE (KAMERA / GALERI)
  // =====================================================
  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        imageUrl = picked.path;
      });
    }
  }

  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Ambil dari Kamera"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Pilih dari Galeri"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // SIMPAN BARANG
  // =====================================================
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final nama = _namaC.text.trim();
    final kode = _kodeC.text.trim().toUpperCase();
    final kondisi = _kondisiC.text.trim();
    final deskripsi = _deskripsiC.text.trim();

    // Cek duplikasi kode saat tambah
    if (!isEdit) {
      final exists = await DatabaseHelper.instance.isKodeBarangExists(kode);
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Kode barang '$kode' sudah digunakan!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final data = {
      "nama": nama,
      "kode": kode,
      "kondisi": kondisi,
      "deskripsi": deskripsi,
      "image_url": imageUrl,
      "created_at": DateTime.now().toIso8601String(),
    };

    if (isEdit) {
      await DatabaseHelper.instance.updateBarang(widget.barang!["id"], data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Barang berhasil diperbarui")),
      );
    } else {
      await DatabaseHelper.instance.insertBarang(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Barang berhasil ditambahkan")),
      );
    }

    Navigator.pop(context, true);
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Barang" : "Tambah Barang Baru"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // FOTO BARANG
              GestureDetector(
                onTap: showImagePicker,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                    image: imageUrl != null
                        ? DecorationImage(
                            image: FileImage(File(imageUrl!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt,
                                  size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Tambah Foto",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // NAMA
              TextFormField(
                controller: _namaC,
                decoration: const InputDecoration(
                  labelText: "Nama Barang",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Nama barang wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // KODE
              TextFormField(
                controller: _kodeC,
                decoration: const InputDecoration(
                  labelText: "Kode Barang (contoh: E001)",
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    v == null || v.isEmpty ? "Kode barang wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // KONDISI
              TextFormField(
                controller: _kondisiC,
                decoration: const InputDecoration(
                  labelText: "Kondisi (Bagus / Rusak Ringan / Rusak Berat)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Kondisi wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // DESKRIPSI
              TextFormField(
                controller: _deskripsiC,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Deskripsi (opsional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // SIMPAN
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEdit ? "Update" : "Simpan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
