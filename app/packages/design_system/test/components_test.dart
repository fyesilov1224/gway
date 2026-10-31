import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {double textScale = 1}) => MaterialApp(
      theme: GwTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('GwAvatar', () {
    testWidgets('user avatar is a circle', (tester) async {
      await tester.pumpWidget(
        _wrap(const GwAvatar(name: 'Ayşe Yılmaz', shape: GwAvatarShape.user)),
      );

      final decoration = tester
          .widget<Container>(find.byType(Container).first)
          .decoration! as ShapeDecoration;
      expect(decoration.shape, isA<CircleBorder>());
      expect(find.text('AY'), findsOneWidget);
    });

    testWidgets('group avatar is a rounded square', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const GwAvatar(
            name: 'Doğa Yürüyüşçüleri',
            shape: GwAvatarShape.group,
            size: GwAvatarSize.lg,
          ),
        ),
      );

      final decoration = tester
          .widget<Container>(find.byType(Container).first)
          .decoration! as ShapeDecoration;
      final shape = decoration.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(GwRadius.lg));
    });

    test('initials follow Turkish casing', () {
      expect(initialsOf('ilker ışık'), 'İI');
      expect(initialsOf('  zeynep  '), 'Z');
      expect(initialsOf('Ali Veli Can'), 'AV');
    });
  });

  group('GwButton', () {
    testWidgets('meets the 44x44 minimum touch target', (tester) async {
      await tester.pumpWidget(
        _wrap(Center(child: GwButton(label: 'Tamam', onPressed: () {}))),
      );

      final size = tester.getSize(find.byType(FilledButton));
      expect(size.width, greaterThanOrEqualTo(GwSpacing.minTouchTarget));
      expect(size.height, greaterThanOrEqualTo(GwSpacing.minTouchTarget));
    });

    testWidgets('ignores taps while loading', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          Center(
            child: GwButton(
              label: 'Kaydet',
              onPressed: () => taps++,
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('secondary variant is outlined', (tester) async {
      await tester.pumpWidget(
        _wrap(
          GwButton(
            label: 'Vazgeç',
            onPressed: () {},
            variant: GwButtonVariant.secondary,
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('GwEmptyState', () {
    testWidgets('shows icon, message and a working action', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          GwEmptyState(
            icon: Icons.groups_outlined,
            message: 'Henüz bir gruba katılmadın.',
            actionLabel: 'Grupları keşfet',
            onAction: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
      expect(find.text('Henüz bir gruba katılmadın.'), findsOneWidget);
      await tester.tap(find.text('Grupları keşfet'));
      expect(tapped, isTrue);
    });

    testWidgets('does not overflow at 130% text scale on a small screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          GwEmptyState(
            icon: Icons.event_outlined,
            message: 'Bu grubun yaklaşan bir organizasyonu bulunmuyor.',
            actionLabel: 'Organizasyon oluştur',
            onAction: () {},
          ),
          textScale: 1.3,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('GwSkeleton', () {
    testWidgets('stays still when animations are disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: GwSkeleton(height: 16),
          ),
        ),
      );

      // pumpAndSettle would time out if the pulse kept repeating.
      await tester.pumpAndSettle();
      expect(find.byType(GwSkeleton), findsOneWidget);
    });
  });
}
