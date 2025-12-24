class Riwayat {
  final int? id;
  final int userId;
  final int barangId;
  final String tanggal;
  final String status; // pinjam / kembali

  Riwayat({
    this.id,
    required this.userId,
    required this.barangId,
    required this.tanggal,
    required this.status,
  });

  factory Riwayat.fromMap(Map<String, dynamic> map) {
    return Riwayat(
      id: map['id'],
      userId: map['user_id'],
      barangId: map['barang_id'],
      tanggal: map['tanggal'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'barang_id': barangId,
      'tanggal': tanggal,
      'status': status,
    };
  }
}
