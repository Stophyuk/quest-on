/// 환경 변수 설정
///
/// IMPORTANT: 이 파일은 .gitignore에 추가되어야 합니다.
/// 실제 배포 시에는 dart-define 또는 flutter_dotenv를 사용하세요.
class Env {
  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ufbajyakzsrumrnehthq.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVmYmFqeWFrenNydW1ybmVodGhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyMzU3MTYsImV4cCI6MjA3NzgxMTcxNn0.ffC1Dxq4zzcWIassEi7ZCeqinOsCQh_sJ1uKBHz3LsQ',
  );

  // Sentry DSN (에러 트래킹)
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
}
