import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashif_mobile/presentation/screens/fuse_box_screen.dart';
import 'package:kashif_mobile/data/repositories/car_fuse_repository.dart';

void main() {
  testWidgets('FuseBoxScreen renders car selector, locations, diagram and Arabic fuse directory', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: FuseBoxScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('خرائط ومخططات علب الفيوزات للسيارات'), findsOneWidget);

    // Verify Car Selector Header is present for default BMW 5-Series E39
    expect(find.text('بي إم دبليو'), findsWidgets);
    expect(find.textContaining('الفئة الخامسة'), findsWidgets);

    // Verify OBD location is shown
    expect(find.textContaining('مدخل الفحص OBD-II:'), findsOneWidget);

    // Verify Fuse Box Location Tabs exist
    expect(find.textContaining('درج التابلوه'), findsWidgets);
    expect(find.textContaining('الشنطة الخلفية'), findsWidgets);

    // Verify Location Info Card
    expect(find.text('مكان علبة الفيوزات في السيارة:'), findsOneWidget);

    // Verify Visual Diagram is present with Authentic Card view
    expect(find.textContaining('بطاقة الوكالة الأصلية'), findsOneWidget);

    // Verify Arabic Fuse Directory Table
    expect(find.textContaining('دليل وجدول الفيوزات بالعربي'), findsOneWidget);
    expect(find.textContaining('F1'), findsWidgets);
    expect(find.textContaining('فيوز مساحات الزجاج الأمامية'), findsOneWidget);

    // Tap a fuse card to verify details sheet opens
    final f1Card = find.textContaining('F1');
    await tester.tap(f1Card.first);
    await tester.pumpAndSettle();

    // Verify Details Sheet content
    expect(find.text('الوظيفة والدائرة الكهربائية:'), findsOneWidget);
    expect(find.text('أعراض تلف واحتراق هذا الفيوز:'), findsOneWidget);
    expect(find.textContaining('نصيحة الفحص:'), findsOneWidget);
  });
}
