import 'package:flutter/material.dart';
import '../models/standings.dart';
import '../services/standings_service.dart';
import '../theme.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  late Future<List<StandingsDivision>> _future;

  @override
  void initState() {
    super.initState();
    _future = StandingsService.fetchStandings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Standings')),
      body: FutureBuilder<List<StandingsDivision>>(
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
    );
  }
}