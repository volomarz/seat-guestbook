/// The sport/league a venue belongs to. Add new entries here first when
/// expanding further (college stadiums, etc.).
enum League { mlb, nfl, nhl, concert, nascar }

extension LeagueX on League {
  String get label {
    switch (this) {
      case League.mlb:
        return 'MLB';
      case League.nfl:
        return 'NFL';
      case League.nhl:
        return 'NHL';
      case League.concert:
        return 'Concerts';
      case League.nascar:
        return 'NASCAR';
    }
  }

  String get emoji {
    switch (this) {
      case League.mlb:
        return '⚾';
      case League.nfl:
        return '🏈';
      case League.nhl:
        return '🏒';
      case League.concert:
        return '🎤';
      case League.nascar:
        return '🏁';
    }
  }

  /// Whether this league has a fixed, browsable list of venues (MLB/NFL/
  /// NHL) vs. being discovered through search (concerts, NASCAR tracks).
  bool get isBrowsable => this == League.mlb || this == League.nfl || this == League.nhl;
}
