/// Mirror dari tabel `logistics_documents` (schema baris 303-314 / README bagian 21).
/// document_type: item_photo | receipt | delivery | condition | other
/// -- dipetakan ke chip "Foto Barang / Nota / Penerimaan / Lainnya" pada desain.
class LogisticsDocumentModel {
  final String id;
  final String logisticsItemId;
  final String documentType;
  final String driveFileId;
  final String? fileName;
  final String? note;
  final String? thumbnailUrl;

  const LogisticsDocumentModel({
    required this.id,
    required this.logisticsItemId,
    required this.documentType,
    required this.driveFileId,
    this.fileName,
    this.note,
    this.thumbnailUrl,
  });

  factory LogisticsDocumentModel.fromMap(Map<String, dynamic> map) {
    return LogisticsDocumentModel(
      id: map['id'] as String,
      logisticsItemId: map['logistics_item_id'] as String,
      documentType: map['document_type'] as String,
      driveFileId: map['drive_file_id'] as String,
      fileName: map['file_name'] as String?,
      note: map['note'] as String?,
      thumbnailUrl: map['thumbnail_url'] as String?,
    );
  }
}
