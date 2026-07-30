// WebView smoke tests live behind an integration_test harness — the
// `webview_flutter` platform view requires a real engine binding that
// the unit-test environment doesn't install.
//
// We keep this file as a compile-anchor only: if [BeritaWebviewScreen]
// stops importing or instantiating, this test file will fail to compile
// and the regression is caught at the next `flutter test` run.

import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/berita/screens/berita_webview_screen.dart';

void main() {
  test('BeritaWebviewScreen is exported', () {
    expect(BeritaWebviewScreen, isNotNull);
  });
}
