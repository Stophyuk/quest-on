import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_on/presentation/widgets/level_up_modal.dart';

void main() {
  group('LevelUpModal Widget', () {
    testWidgets('레벨업 모달 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  LevelUpModal.show(
                    context: context,
                    newLevel: 5,
                    levelTitle: '초보 모험가',
                    character: '🐰',
                  );
                },
                child: const Text('Show Modal'),
              ),
            ),
          ),
        ),
      );

      // 버튼 탭하여 모달 열기
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // 모달 내용 확인
      expect(find.text('🎉 레벨 업! 🎉'), findsOneWidget);
      expect(find.text('Lv.5'), findsOneWidget);
      expect(find.text('초보 모험가'), findsOneWidget);
      expect(find.text('🐰'), findsOneWidget);
      expect(find.text('멋져요!'), findsOneWidget);
    });

    testWidgets('확인 버튼으로 모달 닫기', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  LevelUpModal.show(
                    context: context,
                    newLevel: 10,
                    levelTitle: '숙련된 퀘스터',
                    character: '🦊',
                  );
                },
                child: const Text('Show Modal'),
              ),
            ),
          ),
        ),
      );

      // 모달 열기
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // 모달이 표시됨
      expect(find.text('🎉 레벨 업! 🎉'), findsOneWidget);

      // 확인 버튼 탭
      await tester.tap(find.text('멋져요!'));
      await tester.pumpAndSettle();

      // 모달이 닫힘
      expect(find.text('🎉 레벨 업! 🎉'), findsNothing);
    });

    testWidgets('애니메이션이 작동하는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  LevelUpModal.show(
                    context: context,
                    newLevel: 3,
                    levelTitle: '견습 모험가',
                    character: '🐱',
                  );
                },
                child: const Text('Show Modal'),
              ),
            ),
          ),
        ),
      );

      // 모달 열기
      await tester.tap(find.text('Show Modal'));
      await tester.pump(); // 애니메이션 시작

      // FadeTransition과 ScaleTransition이 존재하는지 확인
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);

      // 애니메이션 완료 대기
      await tester.pumpAndSettle();

      // 모달 내용 확인
      expect(find.text('🐱'), findsOneWidget);
    });

    testWidgets('다양한 레벨 표시 테스트', (WidgetTester tester) async {
      final testCases = [
        (level: 1, title: '초보자', character: '🐰'),
        (level: 50, title: '마스터', character: '🦊'),
        (level: 99, title: '전설', character: '🐻'),
      ];

      for (final testCase in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    LevelUpModal.show(
                      context: context,
                      newLevel: testCase.level,
                      levelTitle: testCase.title,
                      character: testCase.character,
                    );
                  },
                  child: const Text('Show Modal'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        expect(find.text('Lv.${testCase.level}'), findsOneWidget);
        expect(find.text(testCase.title), findsOneWidget);
        expect(find.text(testCase.character), findsOneWidget);

        // 모달 닫기
        await tester.tap(find.text('멋져요!'));
        await tester.pumpAndSettle();
      }
    });
  });
}
