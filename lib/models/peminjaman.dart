class Peminjaman {
  final int? id;
  final int userId;
  final int barangId;
  final String tanggalPinjam;
  final String? status; // pending / approved / returned
  final int? approvedBy;
  final String? approvedAt;

  Peminjaman({
    this.id,
    required this.userId,
    required this.barangId,
    required this.tanggalPinjam,
    this.status,
    this.approvedBy,
    this.approvedAt,
  });

  factory Peminjaman.fromMap(Map<String, dynamic> map) {
    return Peminjaman(
      id: map['id'],
      userId: map['user_id'],
      barangId: map['barang_id'],
      tanggalPinjam: map['tanggal_pinjam'],
      status: map['status'],
      approvedBy: map['approved_by'],
      approvedAt: map['approved_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'barang_id': barangId,
      'tanggal_pinjam': tanggalPinjam,
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
    };
  }
}
