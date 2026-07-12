/// A venue found via Ticketmaster's venue search, used when someone looks
/// up a concert venue to sign a seat at (as opposed to picking from the
/// fixed MLB/NFL stadium lists).
class VenueSearchResult {
  final String ticketmasterId;
  final String name;
  final String city;
  final String state;

  VenueSearchResult({
    required this.ticketmasterId,
    required this.name,
    required this.city,
    required this.state,
  });

  /// Combined "City, ST" display string, or just city if state is unknown.
  String get cityLine => state.isEmpty ? city : '$city, $state';
}
