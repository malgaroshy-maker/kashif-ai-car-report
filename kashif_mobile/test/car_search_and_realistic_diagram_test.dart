import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashif_mobile/data/repositories/car_fuse_repository.dart';
import 'package:kashif_mobile/presentation/screens/fuse_box_screen.dart';

void main() {
  test('CarFuseRepository includes Mercedes-Benz, BMW and supports searchCars', () {
    // 1. Verify Mercedes cars exist
    final mercedesCars = CarFuseRepository.searchCars('mercedes');
    expect(mercedesCars.isNotEmpty, isTrue);
    expect(mercedesCars.any((c) => c.model.contains('W204')), isTrue);
    expect(mercedesCars.any((c) => c.model.contains('W211')), isTrue);

    // 2. Verify BMW cars exist
    final bmwCars = CarFuseRepository.searchCars('bmw');
    expect(bmwCars.isNotEmpty, isTrue);
    expect(bmwCars.any((c) => c.model.contains('E90')), isTrue);
    expect(bmwCars.any((c) => c.model.contains('F10') || c.model.contains('E60')), isTrue);
    expect(bmwCars.any((c) => c.model.contains('X5')), isTrue);

    // 3. Verify searching by Arabic query works
    final mercedesArabic = CarFuseRepository.searchCars('مرسيدس');
    expect(mercedesArabic.isNotEmpty, isTrue);

    final bmwArabic = CarFuseRepository.searchCars('بي إم دبليو');
    expect(bmwArabic.isNotEmpty, isTrue);

    // 4. Verify unique locations exist
    final w204 = CarFuseRepository.getCarById('mercedes_c_class_w204')!;
    expect(w204.fuseBoxes.any((b) => b.isSpecialLocation), isTrue);
    final prefuse = w204.fuseBoxes.firstWhere((b) => b.isSpecialLocation);
    expect(prefuse.slots.any((s) => s.ratingAmps >= 80), isTrue);

    final e90 = CarFuseRepository.getCarById('bmw_3_series_e90_f30')!;
    expect(e90.fuseBoxes.any((b) => b.isSpecialLocation), isTrue);
  });

  testWidgets('FuseBoxScreen allows searching car and exploring realistic diagram & unique locations', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: FuseBoxScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Search Button exists
    final searchBtn = find.text('بحث عن سيارة');
    expect(searchBtn, findsOneWidget);

    // 2. Tap Search Button to open modal
    await tester.tap(searchBtn);
    await tester.pumpAndSettle();

    // Verify Modal opened
    expect(find.textContaining('البحث عن سيارة وموديل'), findsOneWidget);

    // Enter BMW in search field
    final searchInput = find.byType(TextField).last;
    await tester.enterText(searchInput, 'BMW');
    await tester.pumpAndSettle();

    // Verify BMW results
    expect(find.textContaining('الفئة الثالثة'), findsOneWidget);

    // Tap BMW 3 Series
    await tester.tap(find.textContaining('الفئة الثالثة').first);
    await tester.pumpAndSettle();

    // 3. Verify BMW is now active
    expect(find.textContaining('الفئة الثالثة'), findsWidgets);
    expect(find.textContaining('خلف درج التابلوه'), findsWidgets);

    // 4. Verify Unique Location Card exists for BMW (صندوق إلكترونيات المحرك)
    expect(find.textContaining('صندوق إلكترونيات المحرك'), findsWidgets);
    expect(find.textContaining('[موقع فريد وحساس]'), findsWidgets);

    // Switch to the unique E-Box location
    final eBoxFinder = find.textContaining('صندوق إلكترونيات المحرك');
    await tester.ensureVisible(eBoxFinder.first);
    await tester.pumpAndSettle();
    await tester.tap(eBoxFinder.first);
    await tester.pumpAndSettle();

    // Verify Valvetronic / DME fuses are visible
    expect(find.textContaining('VVT / VALVE'), findsWidgets);

    // 5. Verify Realistic Diagram Toggle button exists
    expect(find.text('الملصق'), findsOneWidget);

    // Tap Toggle to switch to Arabic Lid Sticker view
    await tester.tap(find.text('الملصق'));
    await tester.pumpAndSettle();

    // Verify text switched to sticker view mode header
    expect(find.textContaining('ملصق غطاء الفيوزات بالعربي'), findsOneWidget);
  });
}
