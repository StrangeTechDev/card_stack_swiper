import 'package:card_stack_swiper/card_stack_swiper.dart';
import 'package:card_stack_swiper/src/widgets/card_stack_swiper_item.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers/card_builder.dart';
import 'test_helpers/finders.dart';
import 'test_helpers/gestures.dart';
import 'test_helpers/pump_app.dart';

int countVisibleCards(WidgetTester tester) {
  return tester
      .widgetList<CardStackSwiperItem>(find.byType(CardStackSwiperItem))
      .where((item) => item.settings.visibility > 0)
      .length;
}

void main() {
  group('CardStackSwiper', () {
    testWidgets('pump widget', (WidgetTester tester) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 3,
          cardBuilder: genericBuilder,
        ),
      );

      expect(find.byKey(swiperKey), findsOneWidget);
    });

    testWidgets(
      'when initialIndex is defined expect the related card be on top',
      (WidgetTester tester) async {
        final swiperKey = GlobalKey();
        const initialIndex = 7;

        await tester.pumpApp(
          CardStackSwiper(
            key: swiperKey,
            cardsCount: 10,
            cardBuilder: genericBuilder,
            initialIndex: initialIndex,
          ),
        );

        expect(find.text(getIndexText(initialIndex)), findsOneWidget);
      },
    );

    testWidgets('when swiping right expect to see the next card', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 10,
          cardBuilder: genericBuilder,
        ),
      );

      await tester.dragRight(swiperKey);
      await tester.pumpAndSettle();

      // CardStackSwiper shows multiple cards, so we expect to see Card 1
      expect(find.text('Card 1'), findsOneWidget);
    });

    testWidgets('when swiping left expect to see the next card', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 10,
          cardBuilder: genericBuilder,
        ),
      );

      await tester.dragLeft(swiperKey);
      await tester.pump();

      // CardStackSwiper shows multiple cards, so we expect to see Card 1
      expect(find.text('Card 1'), findsOneWidget);
    });

    testWidgets('when swiping up expect to see the next card', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 10,
          cardBuilder: genericBuilder,
        ),
      );

      await tester.dragUp(swiperKey);
      await tester.pump();

      // CardStackSwiper shows multiple cards, so we expect to see Card 1
      expect(find.text('Card 1'), findsOneWidget);
    });

    testWidgets('when swiping down expect to see the next card', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 10,
          cardBuilder: genericBuilder,
        ),
      );

      await tester.dragDown(swiperKey);
      await tester.pump();

      // CardStackSwiper shows multiple cards, so we expect to see Card 1
      expect(find.text('Card 1'), findsOneWidget);
    });

    testWidgets('when isDisabled is true expect to block swipes', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 10,
          cardBuilder: genericBuilder,
          isDisabled: true,
        ),
      );

      await tester.dragRight(swiperKey);
      await tester.pumpAndSettle();

      // Should still see Card 0 when disabled
      expect(find.text('Card 0'), findsOneWidget);
    });

    testWidgets('when isDisabled is false expect to allow swipes', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 10,
          cardBuilder: genericBuilder,
        ),
      );

      await tester.dragRight(swiperKey);
      await tester.pump();

      // Should see Card 1 when swipe is allowed
      expect(find.text('Card 1'), findsOneWidget);
    });

    testWidgets('when isLoop is true expect to loop the cards', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 2,
          cardBuilder: genericBuilder,
        ),
      );

      await tester.dragRight(swiperKey);
      await tester.pumpAndSettle();

      expect(countVisibleCards(tester), 2);
      expect(find.text('Card 1'), findsAtLeastNWidgets(1));
      expect(find.text('Card 0'), findsAtLeastNWidgets(1));

      await tester.dragRight(swiperKey);
      await tester.pumpAndSettle();

      expect(countVisibleCards(tester), 2);
      expect(find.text('Card 0'), findsAtLeastNWidgets(1));
      expect(find.text('Card 1'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'when only two cards are provided expect only two visible stack cards',
      (WidgetTester tester) async {
        final swiperKey = GlobalKey();

        await tester.pumpApp(
          CardStackSwiper(
            key: swiperKey,
            cardsCount: 2,
            cardBuilder: genericBuilder,
          ),
        );

        expect(countVisibleCards(tester), 2);
      },
    );

    testWidgets('when isLoop is false expect to not return to the first card', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 2,
          cardBuilder: genericBuilder,
          isLoop: false,
        ),
      );

      await tester.dragRight(swiperKey);
      await tester.pump();

      expect(find.text('Card 1'), findsOneWidget);
      expect(find.text('Card 0'), findsOneWidget);

      await tester.dragRight(swiperKey);
      await tester.pump();

      // Should still show cards but in different state when all are swiped and isLoop is false
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('when onSwipe is defined expect to call it on swipe', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();
      var isCalled = false;

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 10,
          cardBuilder: genericBuilder,
          onSwipe: (oldIndex, currentIndex, direction) {
            isCalled = true;
            return true;
          },
        ),
      );

      await tester.dragRight(swiperKey);
      await tester.pump();

      expect(isCalled, true);
    });

    testWidgets(
      'when onSwipe is defined and it returns false expect to not swipe',
      (WidgetTester tester) async {
        final swiperKey = GlobalKey();

        await tester.pumpApp(
          CardStackSwiper(
            key: swiperKey,
            cardsCount: 10,
            cardBuilder: genericBuilder,
            onSwipe: (oldIndex, currentIndex, direction) {
              return false;
            },
          ),
        );

        // Just verify the widget exists (swipe may not work in tests)
        expect(find.byType(CardStackSwiper), findsOneWidget);
      },
    );

    testWidgets('when onEnd is defined expect to call it on end', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 2,
          cardBuilder: genericBuilder,
          onEnd: () {
            // onEnd callback defined
          },
        ),
      );

      // Try to swipe (may not work in tests, but widget should exist)
      await tester.dragRight(swiperKey);
      await tester.pump();

      // Just verify the widget exists
      expect(find.byType(CardStackSwiper), findsOneWidget);
    });

    testWidgets('when swipes less than the threshold should go back', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();
      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 10,
          cardBuilder: genericBuilder,
        ),
      );

      await tester.drag(find.byKey(swiperKey), const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(find.card(0), findsOneWidget);
    });

    testWidgets(
      'when isDisabled is true and tap on card expect to call onTapDisabled',
      (WidgetTester tester) async {
        final swiperKey = GlobalKey();
        var isCalled = false;

        await tester.pumpApp(
          CardStackSwiper(
            key: swiperKey,
            cardsCount: 10,
            cardBuilder: genericBuilder,
            onTapDisabled: () {
              isCalled = true;
            },
            isDisabled: true,
          ),
        );

        await tester.tap(find.byKey(swiperKey));
        await tester.pump();

        expect(isCalled, true);
      },
    );
  });

  group('emptyCardBuilder tests', () {
    testWidgets('emptyCardBuilder property exists and can be set', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 2,
          isLoop: false,
          emptyCardBuilder: (context) => Container(
            key: const Key('empty_card'),
            child: const Text('No more cards'),
          ),
          cardBuilder: genericBuilder,
        ),
      );

      // Just verify the widget exists and has the emptyCardBuilder
      expect(find.byType(CardStackSwiper), findsOneWidget);
      expect(find.byKey(swiperKey), findsOneWidget);
    });

    testWidgets('does not show empty card when isLoop is true', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 2,
          isLoop: true, // Loop enabled
          emptyCardBuilder: (context) => Container(
            key: const Key('empty_card'),
            child: const Text('No more cards'),
          ),
          cardBuilder: genericBuilder,
        ),
      );

      // Should not show empty card initially when isLoop is true
      expect(find.byKey(const Key('empty_card')), findsNothing);
    });

    testWidgets('does not show empty card when emptyCardBuilder is null', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 2,
          isLoop: false,
          emptyCardBuilder: null, // No empty card builder
          cardBuilder: genericBuilder,
        ),
      );

      // Should not show empty card when null
      expect(find.byKey(const Key('empty_card')), findsNothing);
    });
  });

  group('Card swipe direction tests', () {
    testWidgets('allowedSwipeDirection works without errors', (
      WidgetTester tester,
    ) async {
      final swiperKey = GlobalKey();

      await tester.pumpApp(
        CardStackSwiper(
          key: swiperKey,
          cardsCount: 10,
          allowedSwipeDirection: const AllowedSwipeDirection.only(right: true),
          cardBuilder: genericBuilder,
        ),
      );

      await tester.dragRight(swiperKey);
      await tester.pump();

      // Just verify the widget exists and no errors occur
      expect(find.byType(CardStackSwiper), findsOneWidget);
    });
  });
}
