/// The sport/league a venue belongs to. Add new entries here first when
/// expanding to another sport (NHL, NASCAR, concert-only venues, etc.).
enum League { mlb, nfl }

extension LeagueX on League {
  String get label {
    switch (this) {
      case League.mlb:
        return 'MLB';
      case League.nfl:
        return 'NFL';
    }
  }

  String get emoji {
    switch (this) {
      case League.mlb:
        return '⚾';
      case League.nfl:
        return '🏈';
    }
  }
}
