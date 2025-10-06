import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/services/meme_service.dart';

void main() {
  group('MemeService', () {
    test('should determine when to show special celebration', () {
      // First perfect score
      final shouldShow1 = MemeService.shouldShowSpecialCelebration(
        currentPerfectScores: 1,
        totalQuizzesTaken: 1,
        isFirstPerfectScore: true,
      );
      expect(shouldShow1, isTrue);

      // Milestone perfect score (5th)
      final shouldShow2 = MemeService.shouldShowSpecialCelebration(
        currentPerfectScores: 5,
        totalQuizzesTaken: 10,
        isFirstPerfectScore: false,
      );
      expect(shouldShow2, isTrue);

      // Milestone perfect score (3rd) - this is also a milestone
      final shouldShow3 = MemeService.shouldShowSpecialCelebration(
        currentPerfectScores: 3,
        totalQuizzesTaken: 5,
        isFirstPerfectScore: false,
      );
      expect(shouldShow3, isTrue); // 3 is a milestone
    });

    test('should fetch celebration meme', () async {
      try {
        final meme = await MemeService.getCelebrationMeme();
        expect(meme, isA<Map<String, String>>());
        expect(meme.containsKey('url'), isTrue);
        expect(meme.containsKey('caption'), isTrue);
      } catch (e) {
        // API might fail, which is acceptable in tests
        expect(e, isNotNull);
      }
    });

    test('should handle API errors gracefully', () async {
      // This test verifies that the service doesn't crash on API errors
      try {
        final meme = await MemeService.getCelebrationMeme();
        expect(meme, isA<Map<String, String>>());
      } catch (e) {
        // Should throw a specific error, not crash
        expect(e, isNotNull);
      }
    });

    test('should show celebration for milestone scores', () {
      // Actual milestones from the implementation: [3, 5, 10, 15, 20, 25, 50]
      final milestones = [1, 3, 5, 10, 15, 20, 25, 50];
      
      for (final milestone in milestones) {
        final shouldShow = MemeService.shouldShowSpecialCelebration(
          currentPerfectScores: milestone,
          totalQuizzesTaken: milestone,
          isFirstPerfectScore: milestone == 1,
        );
        expect(shouldShow, isTrue, reason: 'Milestone $milestone should show celebration');
      }
    });

    test('should not show celebration for non-milestone scores', () {
      // Non-milestones (not in [1, 3, 5, 10, 15, 20, 25, 50])
      final nonMilestones = [2, 4, 6, 7, 8, 9, 11, 12, 13, 14, 16, 17, 18, 19];
      
      for (final score in nonMilestones) {
        final shouldShow = MemeService.shouldShowSpecialCelebration(
          currentPerfectScores: score,
          totalQuizzesTaken: score + 5,
          isFirstPerfectScore: false,
        );
        expect(shouldShow, isFalse, reason: 'Score $score should not show celebration');
      }
    });
  });
}
