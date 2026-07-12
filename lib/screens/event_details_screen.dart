import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/venue_event.dart';
import '../theme.dart';

/// Full details for a concert/NASCAR event, reached by tapping the "Next
/// Event" banner on a venue's page. Games (MLB/NFL/NHL) don't link here —
/// ticket-buying is Ticketmaster-only for now.
class EventDetailsScreen extends StatelessWidget {
  final VenueEvent event;
  const EventDetailsScreen({super.key, required this.event});

  Future<void> _buyTickets(BuildContext context) async {
    final url = event.ticketUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the ticket link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null)
              Image.network(
                event.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(event.subtitle,
                      style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                  const SizedBox(height: 18),
                  if (event.venueName != null)
                    _detailRow(Icons.place_outlined, event.venueName!,
                        subtitle: event.venueAddress),
                  if (event.priceRange != null)
                    _detailRow(Icons.sell_outlined, 'Tickets from ${event.priceRange}'),
                  if (event.onsaleStatus != null)
                    _detailRow(Icons.confirmation_number_outlined, event.onsaleStatus!),
                  const SizedBox(height: 24),
                  if (event.ticketUrl != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _buyTickets(context),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Buy tickets on Ticketmaster',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'You\'ll be taken to Ticketmaster to complete your purchase.',
                    style: TextStyle(color: AppColors.muted, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle,
                        style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
