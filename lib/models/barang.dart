class Barang {
  final int? id;
  final String nama;
  final String? kode;
  final String? kondisi;
  final int stok;
  final String? imageUrl;
  final String? deskripsi;
  final String? createdAt;

  Barang({
    this.id,
    required this.nama,
    this.kode,
    this.kondisi,
    this.stok = 1,
    this.imageUrl,
    this.deskripsi,
    this.createdAt,
  });

  factory Barang.fromMap(Map<String, dynamic> map) {
    return Barang(
      id: map['id'],
      nama: map['nama'],
      kode: map['kode'],
      kondisi: map['kondisi'],
      stok: map['stok'],
      imageUrl: map['image_url'],
      deskripsi: map['deskripsi'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'kode': kode,
      'kondisi': kondisi,
      'stok': stok,
      'image_url': imageUrl,
      'deskripsi': deskripsi,
      'created_at': createdAt,
    };
  }
}
