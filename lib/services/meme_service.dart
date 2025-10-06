import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class MemeService {
  // Fallback celebration memes (URLs to popular celebration memes)
  static final List<Map<String, String>> _celebrationMemes = [
    {
      'url': 'https://i.imgflip.com/1bij.jpg',
      'title': 'Success Kid',
      'caption': 'Got 100% on the quiz!'
    },
    {
      'url': 'https://i.imgflip.com/26am.jpg',
      'title': 'Futurama Fry',
      'caption': 'Not sure if genius or just lucky'
    },
    {
      'url': 'https://i.imgflip.com/1g8my4.jpg',
      'title': 'Expanding Brain',
      'caption': 'Brain expanding with knowledge'
    },
    {
      'url': 'https://i.imgflip.com/30b1gx.jpg',
      'title': 'Stonks',
      'caption': 'Knowledge Stonks!'
    },
    {
      'url': 'https://i.imgflip.com/261o3j.jpg',
      'title': 'Galaxy Brain',
      'caption': 'Big Brain Energy'
    },
    {
      'url': 'https://i.imgflip.com/1ur9b0.jpg',
      'title': 'Surprised Pikachu',
      'caption': 'When you get 100% unexpectedly'
    },
    // Backup text-based celebrations if images fail
    {
      'url': 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjRkZENzAwIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSI0MCIgZmlsbD0iIzMzMyIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPvCfj4Y8L3RleHQ+PC9zdmc+',
      'title': 'Trophy',
      'caption': '🏆 CHAMPION! 🏆'
    },
    {
      'url': 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjNEVDREMxIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSI0MCIgZmlsbD0iIzMzMyIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPvCfjoU8L3RleHQ+PC9zdmc+',
      'title': 'Star',
      'caption': '⭐ STELLAR PERFORMANCE! ⭐'
    }
  ];

  static final List<String> _celebrationMessages = [
    "🎉 LEGENDARY PERFORMANCE! 🎉",
    "🏆 QUIZ MASTER UNLOCKED! 🏆", 
    "⭐ PERFECT SCORE CHAMPION! ⭐",
    "🔥 ABSOLUTELY ON FIRE! 🔥",
    "💎 DIAMOND TIER ACHIEVED! 💎",
    "🚀 KNOWLEDGE ROCKET LAUNCHED! 🚀",
    "👑 CROWNED THE QUIZ KING/QUEEN! 👑",
    "🌟 STELLAR PERFORMANCE! 🌟"
  ];

  static final List<String> _funnyQuotes = [
    "\"I'm not saying I'm Batman, but have you ever seen me and Batman get a perfect quiz score in the same room?\"",
    "\"My brain is like a steel trap... rusty and illegal in 37 states. But today it worked perfectly!\"",
    "\"I don't always take quizzes, but when I do, I prefer to ace them.\"",
    "\"Some people have a photographic memory. I have a phonographic memory - it skips a lot, but today it played perfectly!\"",
    "\"I'm not a genius, I just play one in this quiz app.\"",
    "\"My knowledge is like a fine wine - it gets better with age, and today it was vintage!\"",
    "\"They say knowledge is power. Today I feel like I could power a small city!\"",
    "\"I came, I saw, I conquered... this quiz!\""
  ];

  // Fetch a random celebration meme
  static Future<Map<String, String>> getCelebrationMeme() async {
    // Always use fallback memes for reliability
    print('Getting celebration meme...');
    return _getRandomFallbackMeme();
  }

  // Get a random success meme from our curated list
  static Map<String, String> _getRandomFallbackMeme() {
    final random = Random();
    final meme = _celebrationMemes[random.nextInt(_celebrationMemes.length)];
    
    return {
      'url': meme['url']!,
      'title': meme['title']!,
      'caption': _getRandomCelebrationMessage(),
    };
  }

  // Get multiple celebration memes for variety
  static Future<List<Map<String, String>>> getMultipleCelebrationMemes({int count = 3}) async {
    final List<Map<String, String>> memes = [];
    
    for (int i = 0; i < count; i++) {
      try {
        final meme = await getCelebrationMeme();
        memes.add(meme);
        
        // Add a small delay between requests to be respectful to APIs
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        // If API fails, add a fallback meme
        memes.add(_getRandomFallbackMeme());
      }
    }
    
    return memes;
  }

  // Get a random celebration message
  static String _getRandomCelebrationMessage() {
    final random = Random();
    return _celebrationMessages[random.nextInt(_celebrationMessages.length)];
  }

  // Get a funny quote for perfect score
  static String getRandomFunnyQuote() {
    final random = Random();
    return _funnyQuotes[random.nextInt(_funnyQuotes.length)];
  }

  // Create a custom celebration data package
  static Map<String, dynamic> createCelebrationPackage() {
    return {
      'message': _getRandomCelebrationMessage(),
      'quote': getRandomFunnyQuote(),
      'timestamp': DateTime.now().toIso8601String(),
      'achievement': 'Perfect Score Master',
      'emoji': ['🎉', '🏆', '⭐', '🔥', '💎', '🚀', '👑', '🌟'][Random().nextInt(8)],
    };
  }

  // Get achievement badges for perfect scores
  static List<Map<String, String>> getAchievementBadges(int perfectScoreCount) {
    final List<Map<String, String>> badges = [];
    
    if (perfectScoreCount >= 1) {
      badges.add({
        'title': 'First Perfect Score',
        'description': 'Achieved your first 100% score!',
        'icon': '🥇',
        'color': 'gold'
      });
    }
    
    if (perfectScoreCount >= 3) {
      badges.add({
        'title': 'Triple Threat',
        'description': 'Three perfect scores achieved!',
        'icon': '🔥',
        'color': 'red'
      });
    }
    
    if (perfectScoreCount >= 5) {
      badges.add({
        'title': 'Quiz Master',
        'description': 'Five perfect scores - you\'re a master!',
        'icon': '👑',
        'color': 'purple'
      });
    }
    
    if (perfectScoreCount >= 10) {
      badges.add({
        'title': 'Legend',
        'description': 'Ten perfect scores - legendary status!',
        'icon': '⚡',
        'color': 'blue'
      });
    }
    
    if (perfectScoreCount >= 20) {
      badges.add({
        'title': 'Quiz God',
        'description': 'Twenty perfect scores - divine knowledge!',
        'icon': '🌟',
        'color': 'rainbow'
      });
    }
    
    return badges;
  }

  // Generate celebration animation data
  static Map<String, dynamic> getCelebrationAnimation() {
    final animations = [
      {
        'type': 'confetti',
        'duration': 3000,
        'colors': ['#FFD700', '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4'],
      },
      {
        'type': 'fireworks',
        'duration': 2500,
        'colors': ['#FF0000', '#00FF00', '#0000FF', '#FFFF00', '#FF00FF'],
      },
      {
        'type': 'stars',
        'duration': 2000,
        'colors': ['#FFD700', '#FFA500', '#FFFF00'],
      }
    ];
    
    return animations[Random().nextInt(animations.length)];
  }

  // Check if user deserves a special celebration
  static bool shouldShowSpecialCelebration({
    required int currentPerfectScores,
    required int totalQuizzesTaken,
    required bool isFirstPerfectScore,
  }) {
    // Always show for first perfect score
    if (isFirstPerfectScore) return true;
    
    // Show for milestone perfect scores
    if ([3, 5, 10, 15, 20, 25, 50].contains(currentPerfectScores)) return true;
    
    // Show if they've been struggling and finally got a perfect score
    if (totalQuizzesTaken >= 10 && currentPerfectScores == 1) return true;
    
    return false;
  }
}
