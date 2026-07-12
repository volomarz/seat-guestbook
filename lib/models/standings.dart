class StandingsTeam {
  final String name;
  final int wins;
  final int losses;
  final String pct;
  final String gamesBack;

  StandingsTeam({
    required this.name,
    required this.wins,
    required this.losses,
    required this.pct,
    required this.gamesBack,
  });
}

class StandingsDivision {
  final String name;
  final List<StandingsTeam> teams;

  StandingsDivision({required this.name, required this.teams});
}