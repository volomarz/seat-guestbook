enum VenueEventType { game, concert }

class VenueEvent {
  final VenueEventType type;
  final String title;
  final String subtitle;
  final DateTime dateTime;

  VenueEvent({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.dateTime,
  });
}