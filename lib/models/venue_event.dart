enum VenueEventType { game, concert }

class VenueEvent {
  final VenueEventType type;
  final String title;
  final String subtitle;
  final DateTime dateTime;

  // Richer details, only populated for Ticketmaster-sourced events
  // (concerts and NASCAR). Games (MLB/NFL/NHL) leave these null since
  // ticket-buying isn't supported for them yet.
  final String? imageUrl;
  final String? venueName;
  final String? venueAddress;
  final String? priceRange;
  final String? onsaleStatus; // e.g. "On sale", "Off sale", "Cancelled"
  final String? ticketUrl;

  VenueEvent({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.dateTime,
    this.imageUrl,
    this.venueName,
    this.venueAddress,
    this.priceRange,
    this.onsaleStatus,
    this.ticketUrl,
  });

  /// True when there's enough Ticketmaster data to show a details screen.
  bool get hasDetails => type == VenueEventType.concert && ticketUrl != null;
}
