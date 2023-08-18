import 'package:p_limit/p_limit.dart';

// example combined output of the print statements
// 16
// 17
// 18
// 20
// 19
// 11
// 13
// 12
// 14
// 15
// 8
// 7
// 6
// 9
// 10
// 2
// 3
// 1
// 4
// 5
// [20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

void main() async {
  final limit = PLimit<int>(5);

  final mockData = List.generate(20, (index) => 20 - index);
  final futures = mockData.map((i) => limit(() => doWork(i)));

  final results = await Future.wait(futures);
  print(results);
}

Future<int> doWork(int i) async {
  await Future.delayed(Duration(milliseconds: i));
  print(i);
  return i;
}
