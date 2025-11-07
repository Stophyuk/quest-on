import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_on/presentation/widgets/loading_view.dart';

void main() {
  group('LoadingView Widget', () {
    testWidgets('기본 로딩 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingView(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('로딩 중...'), findsOneWidget);
    });

    testWidgets('커스텀 메시지 표시', (WidgetTester tester) async {
      const customMessage = '데이터를 불러오는 중...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingView(message: customMessage),
          ),
        ),
      );

      expect(find.text(customMessage), findsOneWidget);
    });
  });

  group('SmallLoadingIndicator Widget', () {
    testWidgets('작은 로딩 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmallLoadingIndicator(),
          ),
        ),
      );

      final indicator = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ),
      );

      expect(indicator.width, 24.0);
      expect(indicator.height, 24.0);
    });
  });

  group('SkeletonCard Widget', () {
    testWidgets('스켈레톤 카드 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(AnimatedOpacity), findsWidgets);
    });

    testWidgets('애니메이션 동작', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      // 초기 상태
      await tester.pump();

      // 애니메이션 진행 (500ms)
      await tester.pump(const Duration(milliseconds: 500));

      // 애니메이션 계속 진행 (750ms - 절반 시점)
      await tester.pump(const Duration(milliseconds: 750));

      // 애니메이션이 작동하는지 확인 (위젯이 여전히 존재)
      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('커스텀 높이 설정', (WidgetTester tester) async {
      const customHeight = 200.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(height: customHeight),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.minHeight, customHeight);
    });
  });

  group('SkeletonList Widget', () {
    testWidgets('기본 개수(3개) 스켈레톤 카드 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonList(),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsNWidgets(3));
    });

    testWidgets('커스텀 개수 스켈레톤 카드 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonList(itemCount: 5),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsNWidgets(5));
    });

    testWidgets('ListView로 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonList(),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
