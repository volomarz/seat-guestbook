import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/league.dart';
import '../models/standings.dart';
import '../models/super_bowl_result.dart';
import '../services/nfl_standings_service.dart';
import '../services/standings_service.dart';
import '../theme.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  League _league = League.mlb;
  late Future<List<StandingsDivision>> _future;
  Future<SuperBowlResult?>? _superBowlFuture;

  @override
  void initState() {
    super.initState();
    _future = StandingsService.fetchStandings();
  }

  void _switchLeague(League league) {
    if (league == _league) return;
    setState(() {
      _league = league;
      if (league == League.mlb) {
        _future = StandingsService.fetchStandings();
        _superBowlFuture = null;
      } else {
        _future = NflStandingsService.fetchStandings();
        _superBowlFuture =
            NflStandingsService.fetchSuperBowlResult(NflStandingsService.currentSeason());
      }
    });
  }

  int get _seasonYear => _league == League.mlb
      ? StandingsService.currentSeason()
      : NflStandingsService.currentSeason();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Standings')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _leagueTab(League.mlb, '${League.mlb.emoji} MLB'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _leagueTab(League.nfl, '${League.nfl.emoji} NFL'),
                ),
              ],
            ),
          ),
          if (_superBowlFuture != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<SuperBowlResult?>(
                future: _superBowlFuture,
                builder: (context, snapshot) {
                  final result = snapshot.data;
                  if (result == null) return const SizedBox.shrink();
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dirt.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.date != null
                                    ? '${result.headline} · ${DateFormat('MMM d, yyyy').format(result.date!)}'
                                    : result.headline,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 12.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${result.winnerName} ${result.winnerScore}, '
                                '${result.loserName} ${result.loserScore}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$_seasonYear season',
                style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<StandingsDivision>>(
              future: _future,
              builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Could not load standings. Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            );
          }
          final divisions = snapshot.data!;
          if (divisions.isEmpty) {
            return const Center(child: Text('No standings available.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: divisions.length,
            itemBuilder: (context, i) {
              final division = divisions[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.line),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(division.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 8),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1),
                        },
                        children: [
                          const TableRow(children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('Team',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.3,
                                      color: AppColors.ink)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('W',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.3,
                                      color: AppColors.ink)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('L',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.3,
                                      color: AppColors.ink)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('PCT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.3,
                                      color: AppColors.ink)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('GB',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.3,
                                      color: AppColors.ink)),
                            ),
                          ]),
                          TableRow(children: List.generate(
                            5,
                            (_) => const Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Divider(color: AppColors.line, height: 1, thickness: 1),
                            ),
                          )),
                          ...division.teams.map((t) => TableRow(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(t.name, style: const TextStyle(fontSize: 13)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text('${t.wins}', style: const TextStyle(fontSize: 13)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text('${t.losses}', style: const TextStyle(fontSize: 13)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(t.pct, style: const TextStyle(fontSize: 13)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(t.gamesBack, style: const TextStyle(fontSize: 13)),
                                ),
                              ])),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
          ),
        ],
      ),
    );
  }

  Widget _leagueTab(League league, String label) {
    final selected = _league == league;
    return OutlinedButton(
      onPressed: () => _switchLeague(league),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.green : Colors.white,
        foregroundColor: selected ? Colors.white : AppColors.ink,
        side: const BorderSide(color: AppColors.line),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}