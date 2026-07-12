import 'dart:async';
import 'package:flutter/material.dart';
import '../models/league.dart';
import '../models/stadium.dart';
import '../models/venue_search_result.dart';
import '../services/recent_venues_service.dart';
import '../services/ticketmaster_service.dart';
import '../theme.dart';
import 'stadium_screen.dart';

class VenueSearchScreen extends StatefulWidget {
  final League league;
  const VenueSearchScreen({super.key, this.league = League.concert});

  @override
  State<VenueSearchScreen> createState() => _VenueSearchScreenState();
}

class _VenueSearchScreenState extends State<VenueSearchScreen> {
  String _query = '';
  Timer? _debounce;
  List<VenueSearchResult> _results = [];
  bool _searching = false;
  List<Stadium> _recent = [];
  bool _loadingRecent = true;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final recent = await RecentVenuesService.getRecent(league: widget.league);
    if (mounted) setState(() {
      _recent = recent;
      _loadingRecent = false;
    });
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _searching = true);
      final results = await TicketmasterService.searchVenues(trimmed);
      if (mounted) {
        setState(() {
          _results = results;
          _searching = false;
        });
      }
    });
  }

  Future<void> _openVenue(Stadium stadium) async {
    await RecentVenuesService.addRecent(stadium);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StadiumScreen(stadium: stadium)),
    );
    _loadRecent(); // refresh the recent list order after coming back
  }

  Stadium _stadiumFromResult(VenueSearchResult r) => Stadium(
        id: 'tm-${r.ticketmasterId}',
        name: r.name,
        team: '',
        city: r.cityLine,
        league: widget.league,
      );

  String get _titleText =>
      widget.league == League.nascar ? '🏁 Find a NASCAR track' : '🎤 Find a concert venue';

  String get _hintText =>
      widget.league == League.nascar ? 'Search any track by name...' : 'Search any venue by name...';

  String get _emptyRecentText => widget.league == League.nascar
      ? 'Search for a track above — any NASCAR speedway or road course. '
          'Tracks you visit will show up here for next time.'
      : 'Search for a venue above — any concert hall, arena, or '
          'amphitheater. Venues you visit will show up here for next time.';

  @override
  Widget build(BuildContext context) {
    final showingSearch = _query.trim().length >= 2;

    return Scaffold(
      appBar: AppBar(title: Text(_titleText)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: _hintText,
              ),
              onChanged: _onQueryChanged,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: showingSearch ? _buildSearchResults() : _buildRecent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text('No venues found. Try a different search.',
            style: TextStyle(color: AppColors.muted)),
      );
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final r = _results[i];
        return _venueCard(
          title: r.name,
          subtitle: r.cityLine,
          onTap: () => _openVenue(_stadiumFromResult(r)),
        );
      },
    );
  }

  Widget _buildRecent() {
    if (_loadingRecent) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_recent.isEmpty) {
      return Center(
        child: Text(
          _emptyRecentText,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted),
        ),
      );
    }
    return ListView.builder(
      itemCount: _recent.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('RECENT VENUES',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.muted)),
          );
        }
        final stadium = _recent[i - 1];
        return _venueCard(
          title: stadium.name,
          subtitle: stadium.city,
          onTap: () => _openVenue(stadium),
        );
      },
    );
  }

  Widget _venueCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
        onTap: onTap,
      ),
    );
  }
}
