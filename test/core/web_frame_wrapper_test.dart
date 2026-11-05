import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/core/widgets/web_frame_wrapper.dart';

void main() {
  testWidgets('WebFrameWrapper shows child when forceWeb is false', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WebFrameWrapper(
          forceWeb: false,
          child: Text('App Content'),
        ),
      ),
    );

    expect(find.text('App Content'), findsOneWidget);
    expect(find.text('Download Android APK'), findsNothing);
  });

  testWidgets(
    'WebFrameWrapper displays APK landing page on mobile screen when web is active',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WebFrameWrapper(
            forceWeb: true,
            child: Text('App Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Mobile landing page elements are visible
      expect(find.text('Rent Tracking'), findsWidgets);
      expect(find.text('Download Android APK'), findsOneWidget);
      expect(
        find.text('Release v2.1.0 • Direct GitHub download'),
        findsOneWidget,
      );
      expect(find.text('Monthly Rent Dues'), findsOneWidget);
      expect(find.text('Payment Records & Receipts'), findsOneWidget);
      expect(find.text('Real-Time Due Statuses'), findsOneWidget);
      expect(find.text('Rent History & Changes'), findsOneWidget);

      // App content is hidden on initial landing view
      expect(find.text('App Content'), findsNothing);

      // Tap "preview web edition in browser"
      final previewButton = find.text('Or preview web edition in browser');
      expect(previewButton, findsOneWidget);
      await tester.ensureVisible(previewButton);
      await tester.tap(previewButton);
      await tester.pumpAndSettle();

      // App content is now displayed along with preview top banner
      expect(find.text('App Content'), findsOneWidget);
      expect(find.text('Download Page'), findsOneWidget);
      expect(find.text('Get APK'), findsOneWidget);

      // Tap "Download Page" to return to landing view
      await tester.tap(find.text('Download Page'));
      await tester.pumpAndSettle();

      expect(find.text('Download Android APK'), findsOneWidget);
      expect(find.text('App Content'), findsNothing);
    },
  );

  testWidgets('WebFrameWrapper displays phone chassis and showcase on desktop', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WebFrameWrapper(
            forceWeb: true,
            child: Text('App Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Desktop showcase panel has features & APK download button
      expect(find.text('Rent Tracking'), findsWidgets);
      expect(find.text('Download Android APK'), findsOneWidget);
      expect(find.text('Monthly Rent Dues'), findsOneWidget);

      // App content is rendered inside the desktop phone frame
      expect(find.text('App Content'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
