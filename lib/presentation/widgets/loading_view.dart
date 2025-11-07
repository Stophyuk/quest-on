import 'package:flutter/material.dart';
import 'package:quest_on/core/theme/app_theme.dart';

/// 로딩 표시 위젯
class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 작은 로딩 인디케이터
class SmallLoadingIndicator extends StatelessWidget {
  final double size;

  const SmallLoadingIndicator({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

/// 스켈레톤 로딩 (카드용)
class SkeletonCard extends StatefulWidget {
  final double height;

  const SkeletonCard({
    super.key,
    this.height = 120,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Card(
          child: Container(
            height: widget.height,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                // 설명
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                // 프로그레스 바
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 스켈레톤 리스트
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => SkeletonCard(height: itemHeight),
    );
  }
}
