import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_service.dart';
import 'course_generator.dart';
import 'class_analyzer.dart';
import 'teacher_chatbot.dart';

/// AI service provider — requires API keys to be configured.
final aiServiceProvider = Provider<AiService>((ref) {
  // In production, load from secure storage / env
  final service = AiService(
    groqApiKey: const String.fromEnvironment('GROQ_API_KEY', defaultValue: ''),
    huggingFaceApiKey: const String.fromEnvironment('HF_API_KEY', defaultValue: ''),
  );
  ref.onDispose(() => service.dispose());
  return service;
});

/// Course generator provider.
final courseGeneratorProvider = Provider<CourseGenerator>((ref) {
  return CourseGenerator(aiService: ref.watch(aiServiceProvider));
});

/// Class analyzer provider.
final classAnalyzerProvider = Provider<ClassAnalyzer>((ref) {
  return ClassAnalyzer(aiService: ref.watch(aiServiceProvider));
});

/// Teacher chatbot provider.
final teacherChatbotProvider = Provider<TeacherChatbot>((ref) {
  return TeacherChatbot(aiService: ref.watch(aiServiceProvider));
});

/// State for course generation.
final courseGenerationStateProvider =
    StateNotifierProvider<CourseGenerationNotifier, AsyncValue<GeneratedCourse?>>(
  (ref) => CourseGenerationNotifier(ref.watch(courseGeneratorProvider)),
);

class CourseGenerationNotifier extends StateNotifier<AsyncValue<GeneratedCourse?>> {
  CourseGenerationNotifier(this._generator) : super(const AsyncValue.data(null));
  final CourseGenerator _generator;

  Future<void> generate({
    required String subject,
    required String level,
    required String chapter,
    required List<String> competencies,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _generator.generateCourse(
        subject: subject, level: level, chapter: chapter, competencies: competencies,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
