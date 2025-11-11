/// 환경 변수 설정
///
/// ⚠️ SECURITY: 모든 민감한 값은 환경 변수로 전달해야 합니다.
///
/// 사용 방법:
/// ```bash
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// ```
///
/// 또는 scripts/run_dev.bat 스크립트 사용
class Env {
  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // ⚠️ 보안: 기본값 제거됨. 환경 변수 필수
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '', // ⚠️ 보안: 기본값 제거됨. 환경 변수 필수
  );

  // Sentry DSN (에러 트래킹)
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// 환경 변수 유효성 검사
  static void validate() {
    final errors = <String>[];

    if (supabaseUrl.isEmpty) {
      errors.add('SUPABASE_URL is not set');
    }
    if (supabaseAnonKey.isEmpty) {
      errors.add('SUPABASE_ANON_KEY is not set');
    }

    if (errors.isNotEmpty) {
      throw Exception(
        'Missing required environment variables:\n'
        '${errors.join('\n')}\n\n'
        'Run with: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...\n'
        'Or use: scripts/run_dev.bat',
      );
    }
  }
}
