import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashif_mobile/presentation/screens/dashboard_lights_screen.dart';
import 'package:kashif_mobile/data/repositories/dashboard_lights_repository.dart';

void main() {
  testWidgets('DashboardLightsScreen renders clean list and details sheet with causes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardLightsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title is present
    expect(find.text('دليل لمبات طبلون السيارة (64 لمبة)'), findsOneWidget);

    // Verify tabs from image 3 & 4 are completely deleted
    expect(find.text('مخطط الطبلون المصور (64)'), findsNothing);
    expect(find.text('لوحة الطبلون والعدادات + الدليل'), findsNothing);
    expect(find.text('شبكة الرموز الـ 64 (عالية الدقة)'), findsNothing);
    expect(find.text('اسحب وكبّر بأصابعك لمعاينة الرموز بدقة'), findsNothing);

    // Verify list items exist
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('كشافات الضباب'), findsOneWidget);

    // Verify "التفاصيل والمسببات" button is present on cards
    final detailsButtons = find.text('التفاصيل والمسببات');
    expect(detailsButtons, findsWidgets);

    // Tap first details button to open bottom sheet
    await tester.tap(detailsButtons.first);
    await tester.pumpAndSettle();

    // Verify details sheet opened with causes (مسبباتها)
    expect(find.text('الشرح ودلالة اللمبة:'), findsOneWidget);
    expect(find.text('مسببات ظهور اللمبة المحتملة:'), findsOneWidget);
    expect(find.text('الإجراء الفوري الموصى به:'), findsOneWidget);
  });
}
