import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashif_mobile/data/models/car_fuse_box.dart';
import 'package:kashif_mobile/data/repositories/car_fuse_repository.dart';
import 'package:kashif_mobile/presentation/screens/fuse_box_screen.dart';

void main() {
  test('CarFuseRepository accurately supports BMW 5 Series E39 and its 4 fuse locations', () {
    // 1. Search by 'e39'
    final e39Results = CarFuseRepository.searchCars('e39');
    expect(e39Results.isNotEmpty, isTrue);

    final e39 = e39Results.first;
    expect(e39.id, equals('bmw_5_series_e39'));
    expect(e39.model, contains('E39'));
    expect(e39.make, equals('BMW'));
    expect(e39.yearRange, contains('1995'));
    expect(e39.fuseBoxes.length, equals(4));

    // 2. Glove box fuses & Authentic Card
    final gloveBox = e39.fuseBoxes.firstWhere((b) => b.id == 'bmw_e39_glove_box');
    expect(gloveBox.locationType, equals(FuseBoxLocationType.cabin));
    expect(gloveBox.cardPartNumber, equals('8 377 849 / E 6957.J'));
    expect(gloveBox.hasPullTab, isTrue);
    expect(gloveBox.equipmentMappings.length, equals(48));

    // Verify key equipment mappings matching user's photo
    expect(
        gloveBox.equipmentMappings
            .any((e) => e.equipmentEnglish == 'Fuel pump' && e.fuseNumbers.contains(17) && e.fuseNumbers.contains(31)),
        isTrue);
    expect(
        gloveBox.equipmentMappings
            .any((e) => e.equipmentEnglish == 'ABS gasoline' && e.fuseNumbers.contains(30) && e.fuseNumbers.contains(31)),
        isTrue);
    expect(
        gloveBox.equipmentMappings
            .any((e) => e.equipmentEnglish == 'Air conditioner' && e.fuseNumbers.contains(9) && e.fuseNumbers.contains(20)),
        isTrue);
    expect(
        gloveBox.equipmentMappings
            .any((e) => e.equipmentEnglish == 'Horn' && e.fuseNumbers.contains(3) && e.fuseNumbers.contains(38)),
        isTrue);

    expect(gloveBox.slots.any((s) => s.slotId == 'F1'), isTrue); // Wiper
    expect(gloveBox.slots.any((s) => s.slotId == 'F15'), isTrue); // OBD-II
    expect(gloveBox.slots.any((s) => s.slotId == 'F17'), isTrue); // Fuel pump / ABS diesel
    expect(gloveBox.slots.any((s) => s.slotId == 'F31'), isTrue); // Fuel pump / ASC
    expect(gloveBox.slots.any((s) => s.slotId == 'F75' && s.ratingAmps == 50), isTrue); // Aux Fan Maxi
    expect(gloveBox.slots.any((s) => s.slotId == 'F76' && s.ratingAmps == 40), isTrue); // Blower Maxi

    // 3. Trunk box fuses
    final trunkBox = e39.fuseBoxes.firstWhere((b) => b.id == 'bmw_e39_trunk');
    expect(trunkBox.locationType, equals(FuseBoxLocationType.trunk));
    expect(trunkBox.slots.any((s) => s.slotId == 'F54' && s.label == 'FUEL PUMP'), isTrue);
    expect(trunkBox.slots.any((s) => s.slotId == 'R_FP' && s.isRelay), isTrue);

    // 4. E-Box under microfilter (Special location)
    final eBox = e39.fuseBoxes.firstWhere((b) => b.id == 'bmw_e39_ebox');
    expect(eBox.isSpecialLocation, isTrue);
    expect(eBox.slots.any((s) => s.slotId == 'EF1'), isTrue);
    expect(eBox.slots.any((s) => s.slotId == 'EF2'), isTrue);
    expect(eBox.slots.any((s) => s.slotId == 'R_DME' && s.isRelay), isTrue);

    // 5. Footwell Mega fuses (Special location)
    final footwell = e39.fuseBoxes.firstWhere((b) => b.id == 'bmw_e39_footwell_mega');
    expect(footwell.isSpecialLocation, isTrue);
    expect(footwell.slots.any((s) => s.slotId == 'F100' && s.ratingAmps == 200), isTrue);
    expect(footwell.slots.any((s) => s.slotId == 'F106'), isTrue);
  });

  testWidgets('FuseBoxScreen can search and interact with BMW E39', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: FuseBoxScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Open search modal
    final searchBtn = find.text('بحث عن سيارة');
    expect(searchBtn, findsOneWidget);
    await tester.tap(searchBtn);
    await tester.pumpAndSettle();

    // 2. Type e39 in search box
    final searchField = find.byType(TextField).last;
    await tester.enterText(searchField, 'e39');
    await tester.pumpAndSettle();

    // 3. Verify E39 is shown in search results
    final e39Tile = find.widgetWithText(ListTile, 'الفئة الخامسة (5 Series E39)');
    expect(e39Tile, findsOneWidget);

    // 4. Tap E39 to select it
    await tester.tap(e39Tile);
    await tester.pumpAndSettle();

    // 5. Verify BMW E39 is now active
    expect(find.textContaining('E39'), findsWidgets);
    expect(find.textContaining('درج التابلوه'), findsWidgets);

    // 6. Check fuel pump fuse in trunk
    final trunkTab = find.textContaining('فوق البطارية');
    expect(trunkTab, findsWidgets);
    await tester.ensureVisible(trunkTab.first);
    await tester.pumpAndSettle();
    await tester.tap(trunkTab.first);
    await tester.pumpAndSettle();

    expect(find.textContaining('FUEL PUMP'), findsWidgets);
  });
}
