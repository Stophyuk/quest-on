import 'package:flutter/material.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/data/services/purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// 프리미엄 구독 화면
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest ON 프리미엄'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _purchaseService.isPremium
          ? _buildPremiumActiveView()
          : _buildPremiumOffersView(),
    );
  }

  /// 프리미엄 활성화 상태 화면
  Widget _buildPremiumActiveView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.workspace_premium,
              size: 120,
              color: AppTheme.goldColor,
            ),
            const SizedBox(height: 24),
            Text(
              '프리미엄 회원',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldColor,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '광고 없이 모든 기능을\n자유롭게 사용하고 있습니다!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            _buildFeatureItem(Icons.block, '모든 광고 제거'),
            _buildFeatureItem(Icons.stars, '프리미엄 테마'),
            _buildFeatureItem(Icons.backup, '클라우드 백업'),
            _buildFeatureItem(Icons.support, '우선 지원'),
          ],
        ),
      ),
    );
  }

  /// 프리미엄 제안 화면
  Widget _buildPremiumOffersView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // 헤더
          const Icon(
            Icons.workspace_premium,
            size: 80,
            color: AppTheme.goldColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Quest ON 프리미엄',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '광고 없이 더 나은 경험을 누려보세요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 기능 목록
          _buildFeatureCard(
            icon: Icons.block,
            title: '광고 제거',
            description: '모든 배너, 전면, 보상형 광고가 사라집니다',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.palette,
            title: '프리미엄 테마',
            description: '독점 테마와 캐릭터 커스터마이징',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.backup,
            title: '클라우드 백업',
            description: '데이터 안전하게 백업 및 복원',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.support,
            title: '우선 지원',
            description: '빠른 고객 지원 및 새 기능 우선 체험',
          ),
          const SizedBox(height: 32),

          // 구독 상품
          if (_purchaseService.premiumMonthlyProduct != null)
            _buildSubscriptionCard(
              _purchaseService.premiumMonthlyProduct!,
              '월간 구독',
              '매월 자동 갱신',
              false,
            ),
          const SizedBox(height: 16),
          if (_purchaseService.premiumYearlyProduct != null)
            _buildSubscriptionCard(
              _purchaseService.premiumYearlyProduct!,
              '연간 구독',
              '가장 인기! 연간 최대 33% 절약',
              true,
            ),
          const SizedBox(height: 16),
          if (_purchaseService.removeAdsProduct != null)
            _buildSubscriptionCard(
              _purchaseService.removeAdsProduct!,
              '광고 영구 제거',
              '한 번만 구매하면 평생 광고 없음',
              false,
            ),

          const SizedBox(height: 24),

          // 안내 사항
          Text(
            '• 구독은 언제든지 취소 가능합니다\n'
            '• 결제는 Google Play 계정으로 청구됩니다\n'
            '• 구독은 자동으로 갱신되며, 기간 종료 24시간 전에 취소하지 않으면 갱신됩니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 16),

          // 구매 복원 버튼
          TextButton(
            onPressed: _restorePurchases,
            child: const Text('구매 내역 복원'),
          ),
        ],
      ),
    );
  }

  /// 기능 아이템
  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.goldColor, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// 기능 카드
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.goldColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.goldColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 구독 카드
  Widget _buildSubscriptionCard(
    ProductDetails product,
    String title,
    String subtitle,
    bool isRecommended,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isRecommended
            ? AppTheme.goldColor.withOpacity(0.1)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: isRecommended ? AppTheme.goldColor : AppTheme.borderColor,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.goldColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.borderRadius),
                  topRight: Radius.circular(AppConstants.borderRadius),
                ),
              ),
              child: const Center(
                child: Text(
                  '가장 인기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldColor,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _buyProduct(product.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended
                          ? AppTheme.goldColor
                          : AppTheme.primaryColor,
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
                            '구독하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 상품 구매
  Future<void> _buyProduct(String productId) async {
    setState(() => _isLoading = true);

    try {
      final success = await _purchaseService.buyProduct(productId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('구매가 진행 중입니다...'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('구매를 시작할 수 없습니다'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구매 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 구매 복원
  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      await InAppPurchase.instance.restorePurchases();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구매 내역을 복원했습니다'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구매 복원 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
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
