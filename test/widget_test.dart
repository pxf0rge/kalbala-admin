import 'package:flutter_test/flutter_test.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';

void main() {
  test('app constants are set', () {
    expect(AppConstants.appNameEn, 'KalBala Admin');
    expect(AppConstants.bundleId, 'com.rahmani.admin');
  });
}
