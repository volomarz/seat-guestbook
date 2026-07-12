/// Maps our internal stadium ids to ESPN's team abbreviations, used to
/// query ESPN's free public (but unofficial/undocumented) NFL API at
/// site.api.espn.com. Unlike the official MLB Stats API, ESPN doesn't
/// publish or guarantee this endpoint, so it could change or break without
/// notice — that's a tradeoff of there being no free official NFL data
/// source the way there is for MLB.
const Map<String, String> kNflTeamAbbr = {
  'state-farm-stadium': 'ari',
  'mercedes-benz-stadium': 'atl',
  'mt-bank-stadium': 'bal',
  'highmark-stadium': 'buf',
  'bank-of-america-stadium': 'car',
  'soldier-field': 'chi',
  'paycor-stadium': 'cin',
  'huntington-bank-field': 'cle',
  'att-stadium': 'dal',
  'empower-field': 'den',
  'ford-field': 'det',
  'lambeau-field': 'gb',
  'nrg-stadium': 'hou',
  'lucas-oil-stadium': 'ind',
  'everbank-stadium': 'jax',
  'arrowhead-stadium': 'kc',
  'allegiant-stadium': 'lv',
  'sofi-stadium-chargers': 'lac',
  'sofi-stadium-rams': 'lar',
  'hard-rock-stadium': 'mia',
  'us-bank-stadium': 'min',
  'gillette-stadium': 'ne',
  'caesars-superdome': 'no',
  'metlife-stadium-giants': 'nyg',
  'metlife-stadium-jets': 'nyj',
  'lincoln-financial-field': 'phi',
  'acrisure-stadium': 'pit',
  'lumen-field': 'sea',
  'levis-stadium': 'sf',
  'raymond-james-stadium': 'tb',
  'nissan-stadium': 'ten',
  'northwest-stadium': 'wsh',
};
