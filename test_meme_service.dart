// Simple test to verify meme service import
import 'lib/services/meme_service.dart';

void main() {
  print('Testing MemeService...');
  final meme = MemeService.getRandomFunnyQuote();
  print('Meme service working: $meme');
}
