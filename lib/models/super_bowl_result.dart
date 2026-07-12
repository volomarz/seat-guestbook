class SuperBowlResult {
  final String headline; // e.g. "Super Bowl LX"
  final DateTime? date;
  final String winnerName;
  final String winnerScore;
  final String loserName;
  final String loserScore;

  SuperBowlResult({
    required this.headline,
    this.date,
    required this.winnerName,
    required this.winnerScore,
    required this.loserName,
    required this.loserScore,
  });
}
