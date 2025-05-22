extension RoleExtension on String {
  String convertKorean() {
    switch (this) {
      case 'youth':
        return '청년';
      case 'senior':
        return '노인';
      default:
        return '사용자';
    }
  }
}
