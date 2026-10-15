import 'package:ponjika/ponjika.dart';

void main() {
  const calendar = BanglaCalendar();
  final date = calendar.fromGregorian(DateTime.utc(2025, 4, 17));
  // ignore: avoid_print
  print(BanglaDateFormat('EEEE, d MMMM yyyy • SSSS').format(date));
  final restored = BanglaDateFormat.iso().parse('1432-01-04');
  assert(restored == date);
  final event = BanglaAnnualEvent(
    id: 'new-year',
    title: 'Pohela Boishakh',
    month: 1,
    day: 1,
  );
  // ignore: avoid_print
  print(event.nextOccurrence(date)?.toGregorian());
}
