enum SkillLevel {
  beginner,
  casual,
  competitive,
  pro;

  static SkillLevel fromApi(String value) {
    switch (value.toLowerCase()) {
      case 'beginner': return SkillLevel.beginner;
      case 'casual': return SkillLevel.casual;
      case 'competitive': return SkillLevel.competitive;
      case 'pro': return SkillLevel.pro;
      default: throw FormatException('Unknown SkillLevel: $value');
    }
  }
}
