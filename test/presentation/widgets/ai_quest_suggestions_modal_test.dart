import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_on/presentation/widgets/ai_quest_suggestions_modal.dart';

void main() {
  group('AiQuestSuggestionsModal Widget', () {
    final mockSuggestions = [
      {
        'title': '아침 스트레칭 5분',
        'difficulty': 'easy',
        'category': '건강',
        'estimatedTime': 5,
        'reason': '몸을 깨우고 혈액순환을 개선합니다',
        'stackingTip': '기상 후 바로 시작하세요',
      },
      {
        'title': '책 30분 읽기',
        'difficulty': 'normal',
        'category': '학습',
        'estimatedTime': 30,
        'reason': '독서 습관을 만들어 지식을 쌓습니다',
        'stackingTip': '아침 식사 후 독서하세요',
      },
      {
        'title': '프로젝트 기획안 작성',
        'difficulty': 'hard',
        'category': '생산성',
        'estimatedTime': 60,
        'reason': '프로젝트 성공을 위한 기초 작업입니다',
      },
    ];

    testWidgets('AI 추천 모달 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AiQuestSuggestionsModal.show(
                    context: context,
                    suggestions: mockSuggestions,
                    onQuestSelect: (quest) {},
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

      // 헤더 확인
      expect(find.text('AI 퀘스트 추천'), findsOneWidget);
      expect(find.text('탭하여 퀘스트 추가'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('추천 퀘스트 목록 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AiQuestSuggestionsModal.show(
                    context: context,
                    suggestions: mockSuggestions,
                    onQuestSelect: (quest) {},
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

      // 모든 추천 퀘스트가 표시되는지 확인
      expect(find.text('아침 스트레칭 5분'), findsOneWidget);
      expect(find.text('책 30분 읽기'), findsOneWidget);
      expect(find.text('프로젝트 기획안 작성'), findsOneWidget);

      // 난이도 배지 확인
      expect(find.text('쉬움'), findsOneWidget);
      expect(find.text('보통'), findsOneWidget);
      expect(find.text('어려움'), findsOneWidget);

      // 예상 시간 표시 확인
      expect(find.text('약 5분'), findsOneWidget);
      expect(find.text('약 30분'), findsOneWidget);
      expect(find.text('약 60분'), findsOneWidget);
    });

    testWidgets('추천 이유 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AiQuestSuggestionsModal.show(
                    context: context,
                    suggestions: mockSuggestions,
                    onQuestSelect: (quest) {},
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

      // 추천 이유가 표시되는지 확인
      expect(find.text('몸을 깨우고 혈액순환을 개선합니다'), findsOneWidget);
      expect(find.text('독서 습관을 만들어 지식을 쌓습니다'), findsOneWidget);
      expect(find.text('프로젝트 성공을 위한 기초 작업입니다'), findsOneWidget);
    });

    testWidgets('습관 쌓기 팁 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AiQuestSuggestionsModal.show(
                    context: context,
                    suggestions: mockSuggestions,
                    onQuestSelect: (quest) {},
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

      // 스택킹 팁이 표시되는지 확인
      expect(find.text('기상 후 바로 시작하세요'), findsOneWidget);
      expect(find.text('아침 식사 후 독서하세요'), findsOneWidget);
    });

    testWidgets('퀘스트 선택 콜백 호출', (WidgetTester tester) async {
      Map<String, dynamic>? selectedQuest;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AiQuestSuggestionsModal.show(
                    context: context,
                    suggestions: mockSuggestions,
                    onQuestSelect: (quest) {
                      selectedQuest = quest;
                    },
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

      // 첫 번째 퀘스트 카드 탭
      await tester.tap(find.text('아침 스트레칭 5분'));
      await tester.pumpAndSettle();

      // 콜백이 호출되었는지 확인
      expect(selectedQuest, isNotNull);
      expect(selectedQuest?['title'], '아침 스트레칭 5분');
      expect(selectedQuest?['difficulty'], 'easy');

      // 모달이 닫혔는지 확인
      expect(find.text('AI 퀘스트 추천'), findsNothing);
    });

    testWidgets('닫기 버튼으로 모달 닫기', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AiQuestSuggestionsModal.show(
                    context: context,
                    suggestions: mockSuggestions,
                    onQuestSelect: (quest) {},
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

      // 모달이 열림
      expect(find.text('AI 퀘스트 추천'), findsOneWidget);

      // 닫기 버튼 탭
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 모달이 닫힘
      expect(find.text('AI 퀘스트 추천'), findsNothing);
    });

    testWidgets('DraggableScrollableSheet 동작', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AiQuestSuggestionsModal.show(
                    context: context,
                    suggestions: mockSuggestions,
                    onQuestSelect: (quest) {},
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

      // DraggableScrollableSheet이 존재하는지 확인
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);

      // 핸들이 표시되는지 확인
      final handle = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.margin == const EdgeInsets.only(top: 12) &&
            widget.constraints?.maxWidth == 40,
      );
      expect(handle, findsOneWidget);
    });
  });
}
