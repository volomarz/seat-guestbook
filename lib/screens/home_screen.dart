import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/league.dart';
import '../models/stadium.dart';
import '../services/signatures_store.dart';
import '../theme.dart';
import 'profile_screen.dart';
import 'stadium_screen.dart';
import 'standings_screen.dart';
import 'stats_screen.dart';
import 'venue_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  League? _leagueFilter; // null = show all leagues

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SignaturesStore>();
    final query = _query.trim().toLowerCase();
    final filtered = kStadiums.where((s) {
      final matchesLeague = _leagueFilter == null || s.league == _leagueFilter;
      final matchesQuery = query.isEmpty ||
          (s.name + s.team + s.city).toLowerCase().contains(query);
      return matchesLeague && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 SeatShots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Your profile',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StandingsScreen()),
            ),
            child: const Text('Standings', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
            child: const Text('Stats', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search stadium, team, or city...',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _leagueChip(null, 'All'),
                _leagueChip(League.mlb, '${League.mlb.emoji} MLB'),
                _leagueChip(League.nfl, '${League.nfl.emoji} NFL'),
                _leagueChip(League.nhl, '${League.nhl.emoji} NHL'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Or search: ',
                    style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
                _searchLink(
                  label: '${League.concert.emoji} Concerts',
                  league: League.concert,
                ),
                const SizedBox(width: 14),
                _searchLink(
                  label: '${League.nascar.emoji} NASCAR',
                  league: League.nascar,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No stadiums match your search.',
                          style: TextStyle(color: AppColors.muted)),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final stadium = filtered[i];
                        final count = store.forStadium(stadium.id).length;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.line),
                          ),
                          elevation: 0,
                          child: ListTile(
                            title: Text(stadium.name,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${stadium.team} · ${stadium.city}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: count == 0
                                    ? const Color(0xFFE6E2D3)
                                    : AppColors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  color: count == 0 ? AppColors.muted : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StadiumScreen(stadium: stadium),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leagueChip(League? league, String label) {
    final selected = _leagueFilter == league;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _leagueFilter = league),
      selectedColor: AppColors.green,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.line),
    );
  }

  Widget _searchLink({required String label, required League league}) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VenueSearchScreen(league: league)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.green,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}