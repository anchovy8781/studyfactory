/// 100 collectible food cards for the gacha system.
class FoodCard {
  const FoodCard(this.id, this.name, this.emoji, this.rarity, {this.effect = ''});
  final int id;
  final String name;
  final String emoji;
  final String rarity; // common | rare | epic | legendary

  /// Special ability description. Legendary cards each grant a points boost.
  final String effect;

  bool get isLegendary => rarity == 'legendary';
}

const foodCards = <FoodCard>[
  FoodCard(1, '한우 스테이크', '🥩', 'legendary', effect: '학습 포인트 1.1배'),
  FoodCard(2, '랍스터', '🦞', 'legendary', effect: '학습 포인트 1.1배'),
  FoodCard(3, '캐비어', '🥚', 'legendary', effect: '학습 포인트 1.1배'),
  FoodCard(4, '트러플 파스타', '🍝', 'legendary', effect: '학습 포인트 1.1배'),
  FoodCard(5, '황금 케이크', '🎂', 'legendary', effect: '학습 포인트 1.1배'),
  FoodCard(6, '초밥 모둠', '🍣', 'epic'),
  FoodCard(7, '스테이크', '🍖', 'epic'),
  FoodCard(8, '연어회', '🍣', 'epic'),
  FoodCard(9, '장어구이', '🐟', 'epic'),
  FoodCard(10, '갈비찜', '🍲', 'epic'),
  FoodCard(11, '전복죽', '🦪', 'epic'),
  FoodCard(12, '불고기', '🥘', 'epic'),
  FoodCard(13, '삼겹살', '🥓', 'epic'),
  FoodCard(14, '타코', '🌮', 'epic'),
  FoodCard(15, '피자', '🍕', 'epic'),
  FoodCard(16, '파에야', '🥘', 'epic'),
  FoodCard(17, '마카롱', '🧁', 'epic'),
  FoodCard(18, '치킨', '🍗', 'rare'),
  FoodCard(19, '햄버거', '🍔', 'rare'),
  FoodCard(20, '라멘', '🍜', 'rare'),
  FoodCard(21, '초밥', '🍣', 'rare'),
  FoodCard(22, '떡볶이', '🍢', 'rare'),
  FoodCard(23, '김밥', '🍙', 'rare'),
  FoodCard(24, '냉면', '🍜', 'rare'),
  FoodCard(25, '비빔밥', '🍚', 'rare'),
  FoodCard(26, '돈까스', '🍱', 'rare'),
  FoodCard(27, '우동', '🍲', 'rare'),
  FoodCard(28, '카레', '🍛', 'rare'),
  FoodCard(29, '샐러드', '🥗', 'rare'),
  FoodCard(30, '핫도그', '🌭', 'rare'),
  FoodCard(31, '샌드위치', '🥪', 'rare'),
  FoodCard(32, '부리토', '🌯', 'rare'),
  FoodCard(33, '팬케이크', '🥞', 'rare'),
  FoodCard(34, '와플', '🧇', 'rare'),
  FoodCard(35, '도넛', '🍩', 'rare'),
  FoodCard(36, '아이스크림', '🍦', 'rare'),
  FoodCard(37, '케이크', '🍰', 'rare'),
  FoodCard(38, '쿠키', '🍪', 'rare'),
  FoodCard(39, '푸딩', '🍮', 'rare'),
  FoodCard(40, '크로와상', '🥐', 'rare'),
  FoodCard(41, '베이글', '🥯', 'rare'),
  FoodCard(42, '만두', '🥟', 'rare'),
  FoodCard(43, '밥', '🍚', 'common'),
  FoodCard(44, '빵', '🍞', 'common'),
  FoodCard(45, '계란', '🥚', 'common'),
  FoodCard(46, '우유', '🥛', 'common'),
  FoodCard(47, '바나나', '🍌', 'common'),
  FoodCard(48, '사과', '🍎', 'common'),
  FoodCard(49, '딸기', '🍓', 'common'),
  FoodCard(50, '포도', '🍇', 'common'),
  FoodCard(51, '수박', '🍉', 'common'),
  FoodCard(52, '귤', '🍊', 'common'),
  FoodCard(53, '복숭아', '🍑', 'common'),
  FoodCard(54, '체리', '🍒', 'common'),
  FoodCard(55, '토마토', '🍅', 'common'),
  FoodCard(56, '당근', '🥕', 'common'),
  FoodCard(57, '옥수수', '🌽', 'common'),
  FoodCard(58, '감자', '🥔', 'common'),
  FoodCard(59, '고구마', '🍠', 'common'),
  FoodCard(60, '브로콜리', '🥦', 'common'),
  FoodCard(61, '버섯', '🍄', 'common'),
  FoodCard(62, '가지', '🍆', 'common'),
  FoodCard(63, '오이', '🥒', 'common'),
  FoodCard(64, '커피', '☕', 'common'),
  FoodCard(65, '차', '🍵', 'common'),
  FoodCard(66, '주스', '🧃', 'common'),
  FoodCard(67, '탄산음료', '🥤', 'common'),
  FoodCard(68, '초콜릿', '🍫', 'common'),
  FoodCard(69, '사탕', '🍬', 'common'),
  FoodCard(70, '젤리', '🍬', 'common'),
  FoodCard(71, '팝콘', '🍿', 'common'),
  FoodCard(72, '프레첼', '🥨', 'common'),
  FoodCard(73, '치즈', '🧀', 'common'),
  FoodCard(74, '꿀', '🍯', 'common'),
  FoodCard(75, '아보카도', '🥑', 'common'),
  FoodCard(76, '레몬', '🍋', 'common'),
  FoodCard(77, '땅콩', '🥜', 'common'),
  // ── 신규 추가 카드 (78~100) ───────────────────────────────────────────────
  FoodCard(78, '금박 초밥', '🍣', 'legendary', effect: '학습 포인트 1.1배'),
  FoodCard(79, '샥스핀', '🍲', 'legendary', effect: '학습 포인트 1.1배'),
  FoodCard(80, '푸아그라', '🦆', 'legendary', effect: '학습 포인트 1.1배'),
  FoodCard(81, '송로버섯 리조또', '🍚', 'epic'),
  FoodCard(82, '와규 초밥', '🍣', 'epic'),
  FoodCard(83, '킹크랩', '🦀', 'epic'),
  FoodCard(84, '양갈비', '🍖', 'epic'),
  FoodCard(85, '문어숙회', '🐙', 'epic'),
  FoodCard(86, '딤섬', '🥟', 'rare'),
  FoodCard(87, '쌀국수', '🍜', 'rare'),
  FoodCard(88, '팟타이', '🍝', 'rare'),
  FoodCard(89, '규동', '🍱', 'rare'),
  FoodCard(90, '오므라이스', '🍳', 'rare'),
  FoodCard(91, '크레페', '🥞', 'rare'),
  FoodCard(92, '에그타르트', '🥧', 'rare'),
  FoodCard(93, '붕어빵', '🐟', 'common'),
  FoodCard(94, '호떡', '🥮', 'common'),
  FoodCard(95, '계란빵', '🥚', 'common'),
  FoodCard(96, '식혜', '🥛', 'common'),
  FoodCard(97, '약과', '🍪', 'common'),
  FoodCard(98, '미숫가루', '🥤', 'common'),
  FoodCard(99, '오뎅', '🍢', 'common'),
  FoodCard(100, '군밤', '🌰', 'common'),
];

FoodCard foodCardById(int id) =>
    foodCards.firstWhere((c) => c.id == id, orElse: () => foodCards.first);

/// IDs of all legendary cards (each grants a 1.1× learning-points boost).
final legendaryCardIds =
    foodCards.where((c) => c.isLegendary).map((c) => c.id).toSet();

/// Points multiplier from owned legendary cards.
///
/// Each distinct legendary owned adds +0.1× (e.g. 3 legendaries → 1.3×),
/// capped at 2.0× so it stays balanced.
double legendaryPointsMultiplier(Iterable<int> ownedCardIds) {
  final owned = ownedCardIds.where(legendaryCardIds.contains).toSet().length;
  final mult = 1.0 + 0.1 * owned;
  return mult > 2.0 ? 2.0 : mult;
}
