import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/screens/auth/signup_screen.dart';
import 'package:quest_on/presentation/widgets/error_view.dart';

/// 로그인 화면
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('로그인 시도: ${_emailController.text.trim()}');
      await ref.read(authNotifierProvider.notifier).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      print('✅ 로그인 성공! Router의 자동 리다이렉트가 처리합니다.');

      if (mounted) {
        // 로그인 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인되었습니다!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        // Router의 redirect 로직이 자동으로 적절한 화면으로 이동시킵니다
        // (UserStats 로드 상태에 따라 /onboarding 또는 / 로 이동)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorView.getFriendlyMessage(e)),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing * 2),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // 로고 및 타이틀
                const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '컨디션 기반 퀘스트 관리',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // 이메일 입력
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return '올바른 이메일 형식이 아닙니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 비밀번호 입력
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '8자 이상 입력',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 8) {
                      return '비밀번호는 8자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // 비밀번호 찾기
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: 비밀번호 찾기 다이얼로그
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('비밀번호 찾기 기능 구현 예정'),
                        ),
                      );
                    },
                    child: const Text('비밀번호를 잊으셨나요?'),
                  ),
                ),
                const SizedBox(height: 24),

                // 로그인 버튼
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '계정이 없으신가요?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text('회원가입'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 구분선
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '또는',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // 소셜 로그인 버튼들
                _buildSocialLoginButton(
                  onPressed: _handleGoogleLogin,
                  icon: Icons.g_mobiledata,
                  label: 'Google 로그인',
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  borderColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                _buildSocialLoginButton(
                  onPressed: _handleKakaoLogin,
                  icon: Icons.chat_bubble,
                  label: '카카오 로그인',
                  backgroundColor: const Color(0xFFFEE500),
                  textColor: const Color(0xFF191919),
                ),
                // const SizedBox(height: 12),
                // _buildSocialLoginButton(
                //   onPressed: _handleNaverLogin,
                //   icon: Icons.n_mobiledata,
                //   label: '네이버 로그인',
                //   backgroundColor: const Color(0xFF03C75A),
                //   textColor: Colors.white,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1)
              : BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google 로그인 성공!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorView.getFriendlyMessage(e)),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleKakaoLogin() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).signInWithKakao();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카카오 로그인 성공!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorView.getFriendlyMessage(e)),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleNaverLogin() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).signInWithNaver();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('네이버 로그인 성공!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorView.getFriendlyMessage(e)),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
