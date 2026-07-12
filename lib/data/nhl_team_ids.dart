/// Maps our internal stadium ids to ESPN's team abbreviations, used to
/// query ESPN's free public (but unofficial/undocumented) NHL API at
/// site.api.espn.com — same tradeoff as the NFL data source: no official
/// free NHL API exists the way MLB has one, so this could change or break
/// without notice.
const Map<String, String> kNhlTeamAbbr = {
  'honda-center': 'ana',
  'td-garden': 'bos',
  'keybank-center': 'buf',
  'scotiabank-saddledome': 'cgy',
  'lenovo-center': 'car',
  'united-center': 'chi',
  'ball-arena': 'col',
  'nationwide-arena': 'cbj',
  'american-airlines-center': 'dal',
  'little-caesars-arena': 'det',
  'rogers-place': 'edm',
  'amerant-bank-arena': 'fla',
  'crypto-com-arena': 'la',
  'grand-casino-arena': 'min',
  'bell-centre': 'mtl',
  'bridgestone-arena': 'nsh',
  'prudential-center': 'nj',
  'ubs-arena': 'nyi',
  'madison-square-garden': 'nyr',
  'canadian-tire-centre': 'ott',
  'xfinity-mobile-arena': 'phi',
  'ppg-paints-arena': 'pit',
  'sap-center': 'sj',
  'climate-pledge-arena': 'sea',
  'enterprise-center': 'stl',
  'benchmark-international-arena': 'tb',
  'scotiabank-arena': 'tor',
  'delta-center': 'utah',
  'rogers-arena': 'van',
  't-mobile-arena': 'vgk',
  'capital-one-arena': 'wsh',
  'canada-life-centre': 'wpg',
};
