import 'package:intl/intl.dart';

// 시간 포맷 함수
String formatKoreanTime(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('a h:mm').format(dt); // 'AM 10:22' 등
  } catch (_) {
    return '';
  }
}
