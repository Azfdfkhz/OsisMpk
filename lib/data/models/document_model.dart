/// Mirror dari tabel `documents` (schema baris 269-282 / README bagian 17).
/// File fisik ada di Google Drive; di sini hanya metadata + referensi
/// (drive_file_id). `thumbnailUrl` dipakai untuk pratinjau di UI (mock).
class DocumentModel {
  final String id;
  final String? transactionId;
  final String? eventId;
  final String driveFileId;
  final String? fileName;
  final String? note;
  final String? thumbnailUrl;

  const DocumentModel({
    required this.id,
    this.transactionId,
    this.eventId,
    required this.driveFileId,
    this.fileName,
    this.note,
    this.thumbnailUrl,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as String,
      transactionId: map['transaction_id'] as String?,
      eventId: map['event_id'] as String?,
      driveFileId: map['drive_file_id'] as String,
      fileName: map['file_name'] as String?,
      note: map['note'] as String?,
      thumbnailUrl: map['thumbnail_url'] as String?,
    );
  }
}
