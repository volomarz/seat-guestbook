class SeatSignature {
  final String id;
  final String stadiumId;
  final String section;
  final String row;
  final String seat;
  final String name;
  final String date; // yyyy-MM-dd
  final String note;
  final List<String> photoUrls; // Cloud Storage download URLs, may be empty
  final String ownerId; // Firebase Auth uid of whoever created this
  final bool reported;
  final int createdAt;
  final String? gameSummary; // e.g. "Yankees 7, Red Sox 3 (Final)"
  final String? signerFavoriteTeam; // e.g. "New York Yankees"

  SeatSignature({
    required this.id,
    required this.stadiumId,
    required this.section,
    required this.row,
    required this.seat,
    required this.name,
    required this.date,
    required this.note,
    List<String>? photoUrls,
    required this.ownerId,
    this.reported = false,
    required this.createdAt,
    this.gameSummary,
    this.signerFavoriteTeam,
  }) : photoUrls = photoUrls ?? [];

  String get seatKey =>
      '${section.trim().toUpperCase()}|${row.trim().toUpperCase()}|${seat.trim().toUpperCase()}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'stadiumId': stadiumId,
        'section': section,
        'row': row,
        'seat': seat,
        'name': name,
        'date': date,
        'note': note,
        'photoUrls': photoUrls,
        'ownerId': ownerId,
        'reported': reported,
        'createdAt': createdAt,
        'gameSummary': gameSummary,
        'signerFavoriteTeam': signerFavoriteTeam,
      };

  factory SeatSignature.fromJson(Map<String, dynamic> json) {
    List<String> photoUrls;
    final rawList = json['photoUrls'] as List<dynamic>?;
    if (rawList != null) {
      photoUrls = rawList.map((e) => e as String).toList();
    } else {
      // Backward compatibility with seats signed before multi-photo support.
      final legacy = json['photoUrl'] as String?;
      photoUrls = legacy != null ? [legacy] : [];
    }
    return SeatSignature(
      id: json['id'] as String? ?? '',
      stadiumId: json['stadiumId'] as String? ?? '',
      section: json['section'] as String? ?? '',
      row: json['row'] as String? ?? '',
      seat: json['seat'] as String? ?? '',
      name: json['name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      note: json['note'] as String? ?? '',
      photoUrls: photoUrls,
      ownerId: json['ownerId'] as String? ?? '',
      reported: json['reported'] as bool? ?? false,
      createdAt: json['createdAt'] as int? ?? 0,
      gameSummary: json['gameSummary'] as String?,
      signerFavoriteTeam: json['signerFavoriteTeam'] as String?,
    );
  }
}