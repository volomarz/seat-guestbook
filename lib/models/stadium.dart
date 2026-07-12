import 'league.dart';

class Stadium {
  final String id;
  final String name;
  final String team;
  final String city;
  final League league;

  const Stadium({
    required this.id,
    required this.name,
    required this.team,
    required this.city,
    this.league = League.mlb,
  });
}

final List<Stadium> kMlbStadiums = [
  Stadium(id: 'american-family-field', name: 'American Family Field', team: 'Milwaukee Brewers', city: 'Milwaukee, WI'),
  Stadium(id: 'angel-stadium', name: 'Angel Stadium', team: 'Los Angeles Angels', city: 'Anaheim, CA'),
  Stadium(id: 'busch-stadium', name: 'Busch Stadium', team: 'St. Louis Cardinals', city: 'St. Louis, MO'),
  Stadium(id: 'chase-field', name: 'Chase Field', team: 'Arizona Diamondbacks', city: 'Phoenix, AZ'),
  Stadium(id: 'citi-field', name: 'Citi Field', team: 'New York Mets', city: 'Queens, NY'),
  Stadium(id: 'citizens-bank-park', name: 'Citizens Bank Park', team: 'Philadelphia Phillies', city: 'Philadelphia, PA'),
  Stadium(id: 'comerica-park', name: 'Comerica Park', team: 'Detroit Tigers', city: 'Detroit, MI'),
  Stadium(id: 'coors-field', name: 'Coors Field', team: 'Colorado Rockies', city: 'Denver, CO'),
  Stadium(id: 'daikin-park', name: 'Daikin Park', team: 'Houston Astros', city: 'Houston, TX'),
  Stadium(id: 'dodger-stadium', name: 'Dodger Stadium', team: 'Los Angeles Dodgers', city: 'Los Angeles, CA'),
  Stadium(id: 'fenway-park', name: 'Fenway Park', team: 'Boston Red Sox', city: 'Boston, MA'),
  Stadium(id: 'globe-life-field', name: 'Globe Life Field', team: 'Texas Rangers', city: 'Arlington, TX'),
  Stadium(id: 'great-american-ball-park', name: 'Great American Ball Park', team: 'Cincinnati Reds', city: 'Cincinnati, OH'),
  Stadium(id: 'kauffman-stadium', name: 'Kauffman Stadium', team: 'Kansas City Royals', city: 'Kansas City, MO'),
  Stadium(id: 'loandepot-park', name: 'loanDepot park', team: 'Miami Marlins', city: 'Miami, FL'),
  Stadium(id: 'nationals-park', name: 'Nationals Park', team: 'Washington Nationals', city: 'Washington, D.C.'),
  Stadium(id: 'oracle-park', name: 'Oracle Park', team: 'San Francisco Giants', city: 'San Francisco, CA'),
  Stadium(id: 'camden-yards', name: 'Oriole Park at Camden Yards', team: 'Baltimore Orioles', city: 'Baltimore, MD'),
  Stadium(id: 'petco-park', name: 'Petco Park', team: 'San Diego Padres', city: 'San Diego, CA'),
  Stadium(id: 'pnc-park', name: 'PNC Park', team: 'Pittsburgh Pirates', city: 'Pittsburgh, PA'),
  Stadium(id: 'progressive-field', name: 'Progressive Field', team: 'Cleveland Guardians', city: 'Cleveland, OH'),
  Stadium(id: 'rate-field', name: 'Rate Field', team: 'Chicago White Sox', city: 'Chicago, IL'),
  Stadium(id: 'rogers-centre', name: 'Rogers Centre', team: 'Toronto Blue Jays', city: 'Toronto, ON'),
  Stadium(id: 'sutter-health-park', name: 'Sutter Health Park', team: 'Athletics', city: 'West Sacramento, CA'),
  Stadium(id: 't-mobile-park', name: 'T-Mobile Park', team: 'Seattle Mariners', city: 'Seattle, WA'),
  Stadium(id: 'target-field', name: 'Target Field', team: 'Minnesota Twins', city: 'Minneapolis, MN'),
  Stadium(id: 'tropicana-field', name: 'Tropicana Field', team: 'Tampa Bay Rays', city: 'St. Petersburg, FL'),
  Stadium(id: 'truist-park', name: 'Truist Park', team: 'Atlanta Braves', city: 'Cumberland, GA'),
  Stadium(id: 'wrigley-field', name: 'Wrigley Field', team: 'Chicago Cubs', city: 'Chicago, IL'),
  Stadium(id: 'yankee-stadium', name: 'Yankee Stadium', team: 'New York Yankees', city: 'Bronx, NY'),
]..sort((a, b) => a.team.compareTo(b.team));

// NFL stadium names current as of the 2026 season. Two pairs of teams share
// a physical venue (SoFi Stadium: Rams/Chargers, MetLife Stadium: Giants/
// Jets) — each tenant gets its own browsable entry here since our data model
// is one-team-per-entry, so a seat signed during a Rams game and a seat
// signed during a Chargers game at the same physical seat will show up as
// two separate "stadiums" rather than one shared one. Worth revisiting if
// that distinction ever bothers users.
final List<Stadium> kNflStadiums = [
  Stadium(id: 'state-farm-stadium', name: 'State Farm Stadium', team: 'Arizona Cardinals', city: 'Glendale, AZ', league: League.nfl),
  Stadium(id: 'mercedes-benz-stadium', name: 'Mercedes-Benz Stadium', team: 'Atlanta Falcons', city: 'Atlanta, GA', league: League.nfl),
  Stadium(id: 'mt-bank-stadium', name: 'M&T Bank Stadium', team: 'Baltimore Ravens', city: 'Baltimore, MD', league: League.nfl),
  Stadium(id: 'highmark-stadium', name: 'Highmark Stadium', team: 'Buffalo Bills', city: 'Orchard Park, NY', league: League.nfl),
  Stadium(id: 'bank-of-america-stadium', name: 'Bank of America Stadium', team: 'Carolina Panthers', city: 'Charlotte, NC', league: League.nfl),
  Stadium(id: 'soldier-field', name: 'Soldier Field', team: 'Chicago Bears', city: 'Chicago, IL', league: League.nfl),
  Stadium(id: 'paycor-stadium', name: 'Paycor Stadium', team: 'Cincinnati Bengals', city: 'Cincinnati, OH', league: League.nfl),
  Stadium(id: 'huntington-bank-field', name: 'Huntington Bank Field', team: 'Cleveland Browns', city: 'Cleveland, OH', league: League.nfl),
  Stadium(id: 'att-stadium', name: 'AT&T Stadium', team: 'Dallas Cowboys', city: 'Arlington, TX', league: League.nfl),
  Stadium(id: 'empower-field', name: 'Empower Field at Mile High', team: 'Denver Broncos', city: 'Denver, CO', league: League.nfl),
  Stadium(id: 'ford-field', name: 'Ford Field', team: 'Detroit Lions', city: 'Detroit, MI', league: League.nfl),
  Stadium(id: 'lambeau-field', name: 'Lambeau Field', team: 'Green Bay Packers', city: 'Green Bay, WI', league: League.nfl),
  Stadium(id: 'nrg-stadium', name: 'NRG Stadium', team: 'Houston Texans', city: 'Houston, TX', league: League.nfl),
  Stadium(id: 'lucas-oil-stadium', name: 'Lucas Oil Stadium', team: 'Indianapolis Colts', city: 'Indianapolis, IN', league: League.nfl),
  Stadium(id: 'everbank-stadium', name: 'EverBank Stadium', team: 'Jacksonville Jaguars', city: 'Jacksonville, FL', league: League.nfl),
  Stadium(id: 'arrowhead-stadium', name: 'Arrowhead Stadium', team: 'Kansas City Chiefs', city: 'Kansas City, MO', league: League.nfl),
  Stadium(id: 'allegiant-stadium', name: 'Allegiant Stadium', team: 'Las Vegas Raiders', city: 'Las Vegas, NV', league: League.nfl),
  Stadium(id: 'sofi-stadium-chargers', name: 'SoFi Stadium', team: 'Los Angeles Chargers', city: 'Inglewood, CA', league: League.nfl),
  Stadium(id: 'sofi-stadium-rams', name: 'SoFi Stadium', team: 'Los Angeles Rams', city: 'Inglewood, CA', league: League.nfl),
  Stadium(id: 'hard-rock-stadium', name: 'Hard Rock Stadium', team: 'Miami Dolphins', city: 'Miami Gardens, FL', league: League.nfl),
  Stadium(id: 'us-bank-stadium', name: 'U.S. Bank Stadium', team: 'Minnesota Vikings', city: 'Minneapolis, MN', league: League.nfl),
  Stadium(id: 'gillette-stadium', name: 'Gillette Stadium', team: 'New England Patriots', city: 'Foxborough, MA', league: League.nfl),
  Stadium(id: 'caesars-superdome', name: 'Caesars Superdome', team: 'New Orleans Saints', city: 'New Orleans, LA', league: League.nfl),
  Stadium(id: 'metlife-stadium-giants', name: 'MetLife Stadium', team: 'New York Giants', city: 'East Rutherford, NJ', league: League.nfl),
  Stadium(id: 'metlife-stadium-jets', name: 'MetLife Stadium', team: 'New York Jets', city: 'East Rutherford, NJ', league: League.nfl),
  Stadium(id: 'lincoln-financial-field', name: 'Lincoln Financial Field', team: 'Philadelphia Eagles', city: 'Philadelphia, PA', league: League.nfl),
  Stadium(id: 'acrisure-stadium', name: 'Acrisure Stadium', team: 'Pittsburgh Steelers', city: 'Pittsburgh, PA', league: League.nfl),
  Stadium(id: 'lumen-field', name: 'Lumen Field', team: 'Seattle Seahawks', city: 'Seattle, WA', league: League.nfl),
  Stadium(id: 'levis-stadium', name: "Levi's Stadium", team: 'San Francisco 49ers', city: 'Santa Clara, CA', league: League.nfl),
  Stadium(id: 'raymond-james-stadium', name: 'Raymond James Stadium', team: 'Tampa Bay Buccaneers', city: 'Tampa, FL', league: League.nfl),
  Stadium(id: 'nissan-stadium', name: 'Nissan Stadium', team: 'Tennessee Titans', city: 'Nashville, TN', league: League.nfl),
  Stadium(id: 'northwest-stadium', name: 'Northwest Stadium', team: 'Washington Commanders', city: 'Landover, MD', league: League.nfl),
]..sort((a, b) => a.team.compareTo(b.team));

// NHL arena names current as of the 2025-26 season (several arenas were
// renamed under new sponsorship deals in 2025: Tampa Bay's, Philadelphia's,
// and Minnesota's).
final List<Stadium> kNhlStadiums = [
  Stadium(id: 'honda-center', name: 'Honda Center', team: 'Anaheim Ducks', city: 'Anaheim, CA', league: League.nhl),
  Stadium(id: 'td-garden', name: 'TD Garden', team: 'Boston Bruins', city: 'Boston, MA', league: League.nhl),
  Stadium(id: 'keybank-center', name: 'KeyBank Center', team: 'Buffalo Sabres', city: 'Buffalo, NY', league: League.nhl),
  Stadium(id: 'scotiabank-saddledome', name: 'Scotiabank Saddledome', team: 'Calgary Flames', city: 'Calgary, AB', league: League.nhl),
  Stadium(id: 'lenovo-center', name: 'Lenovo Center', team: 'Carolina Hurricanes', city: 'Raleigh, NC', league: League.nhl),
  Stadium(id: 'united-center', name: 'United Center', team: 'Chicago Blackhawks', city: 'Chicago, IL', league: League.nhl),
  Stadium(id: 'ball-arena', name: 'Ball Arena', team: 'Colorado Avalanche', city: 'Denver, CO', league: League.nhl),
  Stadium(id: 'nationwide-arena', name: 'Nationwide Arena', team: 'Columbus Blue Jackets', city: 'Columbus, OH', league: League.nhl),
  Stadium(id: 'american-airlines-center', name: 'American Airlines Center', team: 'Dallas Stars', city: 'Dallas, TX', league: League.nhl),
  Stadium(id: 'little-caesars-arena', name: 'Little Caesars Arena', team: 'Detroit Red Wings', city: 'Detroit, MI', league: League.nhl),
  Stadium(id: 'rogers-place', name: 'Rogers Place', team: 'Edmonton Oilers', city: 'Edmonton, AB', league: League.nhl),
  Stadium(id: 'amerant-bank-arena', name: 'Amerant Bank Arena', team: 'Florida Panthers', city: 'Sunrise, FL', league: League.nhl),
  Stadium(id: 'crypto-com-arena', name: 'Crypto.com Arena', team: 'Los Angeles Kings', city: 'Los Angeles, CA', league: League.nhl),
  Stadium(id: 'grand-casino-arena', name: 'Grand Casino Arena', team: 'Minnesota Wild', city: 'Saint Paul, MN', league: League.nhl),
  Stadium(id: 'bell-centre', name: 'Bell Centre', team: 'Montreal Canadiens', city: 'Montreal, QC', league: League.nhl),
  Stadium(id: 'bridgestone-arena', name: 'Bridgestone Arena', team: 'Nashville Predators', city: 'Nashville, TN', league: League.nhl),
  Stadium(id: 'prudential-center', name: 'Prudential Center', team: 'New Jersey Devils', city: 'Newark, NJ', league: League.nhl),
  Stadium(id: 'ubs-arena', name: 'UBS Arena', team: 'New York Islanders', city: 'Elmont, NY', league: League.nhl),
  Stadium(id: 'madison-square-garden', name: 'Madison Square Garden', team: 'New York Rangers', city: 'New York, NY', league: League.nhl),
  Stadium(id: 'canadian-tire-centre', name: 'Canadian Tire Centre', team: 'Ottawa Senators', city: 'Ottawa, ON', league: League.nhl),
  Stadium(id: 'xfinity-mobile-arena', name: 'Xfinity Mobile Arena', team: 'Philadelphia Flyers', city: 'Philadelphia, PA', league: League.nhl),
  Stadium(id: 'ppg-paints-arena', name: 'PPG Paints Arena', team: 'Pittsburgh Penguins', city: 'Pittsburgh, PA', league: League.nhl),
  Stadium(id: 'sap-center', name: 'SAP Center', team: 'San Jose Sharks', city: 'San Jose, CA', league: League.nhl),
  Stadium(id: 'climate-pledge-arena', name: 'Climate Pledge Arena', team: 'Seattle Kraken', city: 'Seattle, WA', league: League.nhl),
  Stadium(id: 'enterprise-center', name: 'Enterprise Center', team: 'St. Louis Blues', city: 'St. Louis, MO', league: League.nhl),
  Stadium(id: 'benchmark-international-arena', name: 'Benchmark International Arena', team: 'Tampa Bay Lightning', city: 'Tampa, FL', league: League.nhl),
  Stadium(id: 'scotiabank-arena', name: 'Scotiabank Arena', team: 'Toronto Maple Leafs', city: 'Toronto, ON', league: League.nhl),
  Stadium(id: 'delta-center', name: 'Delta Center', team: 'Utah Mammoth', city: 'Salt Lake City, UT', league: League.nhl),
  Stadium(id: 'rogers-arena', name: 'Rogers Arena', team: 'Vancouver Canucks', city: 'Vancouver, BC', league: League.nhl),
  Stadium(id: 't-mobile-arena', name: 'T-Mobile Arena', team: 'Vegas Golden Knights', city: 'Paradise, NV', league: League.nhl),
  Stadium(id: 'capital-one-arena', name: 'Capital One Arena', team: 'Washington Capitals', city: 'Washington, D.C.', league: League.nhl),
  Stadium(id: 'canada-life-centre', name: 'Canada Life Centre', team: 'Winnipeg Jets', city: 'Winnipeg, MB', league: League.nhl),
]..sort((a, b) => a.team.compareTo(b.team));

final List<Stadium> kStadiums = [...kMlbStadiums, ...kNflStadiums, ...kNhlStadiums]
  ..sort((a, b) => a.team.compareTo(b.team));