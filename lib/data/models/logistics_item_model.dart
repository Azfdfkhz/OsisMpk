import 'logistics_document_model.dart';

/// Mirror dari tabel `logistics_items` (schema baris 288-301 / README bagian 20-21).
/// status mengikuti enum logistics_status: PENDING, RECEIVED, ISSUE
/// -- ditampilkan sebagai badge "Diterima" / "Belum" pada desain.
class LogisticsItemModel {
  final String id;
  final String eventId;
  final String name; // Air Mineral, Banner, Konsumsi Panitia, ATK, dst
  final String? description;
  final double quantity;
  final String? unit; // Dus, Buah, Pack, Set, Paket
  final String status;
  final List<LogisticsDocumentModel> documents;

  const LogisticsItemModel({
    required this.id,
    required this.eventId,
    required this.name,
    this.description,
    required this.quantity,
    this.unit,
    required this.status,
    this.documents = const [],
  });

  bool get isReceived => status == 'RECEIVED';

  String get quantityLabel {
    final q = quantity == quantity.roundToDouble() ? quantity.toInt().toString() : quantity.toString();
    return unit != null ? '$q $unit' : q;
  }

  factory LogisticsItemModel.fromMap(Map<String, dynamic> map) {
    return LogisticsItemModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String?,
      status: map['status'] as String,
    );
  }
}
