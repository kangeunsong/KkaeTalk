class UserProfile {
  final String uid;
  final String name;
  final String email;

  // 관심 카테고리 선택 여부
  final bool interestPolitics; // 정치
  final bool interestEconomy; // 경제
  final bool interestSociety; // 사회
  final bool interestLifeCulture; // 생활/문화
  final bool interestItScience; // IT/과학
  final bool interestWorld; // 세계

  // 질문 레벨 (1~3)
  final int questionLevel;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.interestPolitics,
    required this.interestEconomy,
    required this.interestSociety,
    required this.interestLifeCulture,
    required this.interestItScience,
    required this.interestWorld,
    required this.questionLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'interest_politics': interestPolitics,
      'interest_economy': interestEconomy,
      'interest_society': interestSociety,
      'interest_life_culture': interestLifeCulture,
      'interest_it_science': interestItScience,
      'interest_world': interestWorld,
      'question_level': questionLevel,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      interestPolitics: data['interest_politics'] ?? false,
      interestEconomy: data['interest_economy'] ?? false,
      interestSociety: data['interest_society'] ?? false,
      interestLifeCulture: data['interest_life_culture'] ?? false,
      interestItScience: data['interest_it_science'] ?? false,
      interestWorld: data['interest_world'] ?? false,
      questionLevel: data['question_level'] ?? 1,
    );
  }
}
