class Stadium {
  final String id;
  final String name;
  final String team;
  final String city;

  const Stadium({
    required this.id,
    required this.name,
    required this.team,
    required this.city,
  });
}

final List<Stadium> kStadiums = [
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