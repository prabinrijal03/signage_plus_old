import 'package:flutter_test/flutter_test.dart';
import 'package:slashplus/services/utils.dart';

void main() {
  test('split integer with place value', () {
    expect(Utils.splitIntegerWithPlaceValues(2), equals([2]));
    expect(Utils.splitIntegerWithPlaceValues(15), equals([15]));
    expect(Utils.splitIntegerWithPlaceValues(23), equals([20, 3]));
    expect(Utils.splitIntegerWithPlaceValues(55), equals([50, 5]));
    expect(Utils.splitIntegerWithPlaceValues(105), equals([100, 5]));
    expect(Utils.splitIntegerWithPlaceValues(110), equals([100, 10]));
    expect(Utils.splitIntegerWithPlaceValues(119), equals([100, 19]));
    expect(Utils.splitIntegerWithPlaceValues(120), equals([100, 20]));
    expect(Utils.splitIntegerWithPlaceValues(125), equals([100, 20, 5]));
    expect(Utils.splitIntegerWithPlaceValues(205), equals([2, 100, 5]));
    expect(Utils.splitIntegerWithPlaceValues(210), equals([2, 100, 10]));
    expect(Utils.splitIntegerWithPlaceValues(219), equals([2, 100, 19]));
    expect(Utils.splitIntegerWithPlaceValues(220), equals([2, 100, 20]));
    expect(Utils.splitIntegerWithPlaceValues(225), equals([2, 100, 20, 5]));
    expect(Utils.splitIntegerWithPlaceValues(307), equals([3, 100, 7]));
    expect(Utils.splitIntegerWithPlaceValues(314), equals([3, 100, 14]));
    expect(Utils.splitIntegerWithPlaceValues(319), equals([3, 100, 19]));
    expect(Utils.splitIntegerWithPlaceValues(370), equals([3, 100, 70]));
    expect(Utils.splitIntegerWithPlaceValues(355), equals([3, 100, 50, 5]));
  });
}
