class Pengembalian {
  final int? id;
  final int peminjamanId;
  final String? tanggalKembali;
  final String? catatan;
  final String? kondisiBaru;

  Pengembalian({
    this.id,
    required this.peminjamanId,
    this.tanggalKembali,
    this.catatan,
    this.kondisiBaru,
  });

  factory Pengembalian.fromMap(Map<String, dynamic> map) {
    return Pengembalian(
      id: map['id'],
      peminjamanId: map['peminjaman_id'],
      tanggalKembali: map['tanggal_kembali'],
      catatan: map['catatan'],
      kondisiBaru: map['kondisi_baru'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'peminjaman_id': peminjamanId,
      'tanggal_kembali': tanggalKembali,
      'catatan': catatan,
      'kondisi_baru': kondisiBaru,
    };
  }
}
