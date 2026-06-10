import 'dart:async';

import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/features/home/views/components/budget_card.dart';
import 'package:fe_app/features/home/views/components/home_carousel_card.dart';
import 'package:fe_app/features/home/views/components/selection_rate_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeInfoCarousel extends ConsumerStatefulWidget {
  const HomeInfoCarousel({required this.onBudgetTap, super.key});

  final Future<void> Function() onBudgetTap;

  @override
  ConsumerState<HomeInfoCarousel> createState() => _HomeInfoCarouselState();
}

class _HomeInfoCarouselState extends ConsumerState<HomeInfoCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  static double _viewportFractionFor(double screenWidth, double scale) {
    final slotWidth = HomeCarouselCard.pageSlotWidth * scale;
    return (slotWidth / screenWidth).clamp(0.01, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: (HomeCarouselCard.pageSlotWidth / kFigmaDesignWidth)
          .clamp(0.01, 1.0),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = responsiveScale(context);
    final nextFraction = _viewportFractionFor(screenWidth, scale);
    if ((_pageController.viewportFraction - nextFraction).abs() <= 0.0001) {
      return;
    }

    final previousPage = _pageController.hasClients
        ? (_pageController.page?.round() ?? _currentPage)
        : _currentPage;
    final fraction = nextFraction;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if ((_pageController.viewportFraction - fraction).abs() <= 0.0001) {
        return;
      }
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: fraction,
        initialPage: previousPage.clamp(0, 1),
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final summaryAsync = ref.watch(homeSummaryProvider);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40 * scale),
      child: SizedBox(
        height: HomeCarouselCard.designHeight * scale,
        width: screenWidth,
        child: summaryAsync.when(
          loading: () => _pageView(
            scale: scale,
            budgetChild: _cardLoading(scale),
            selectionChild: _cardLoading(scale),
          ),
          error: (_, __) => _pageView(
            scale: scale,
            budgetChild: _cardError(scale, '예산 정보를 불러오지 못했어요.'),
            selectionChild: _cardError(scale, '선택률 정보를 불러오지 못했어요.'),
          ),
          data: (summary) {
            if (summary == null) {
              return _pageView(
                scale: scale,
                budgetChild: _cardLoading(scale),
                selectionChild: _cardLoading(scale),
              );
            }
            return _pageView(
              scale: scale,
              budgetChild: BudgetCard(
                summary: summary,
                onTap: () => unawaited(widget.onBudgetTap()),
              ),
              selectionChild: SelectionRateCard(summary: summary),
            );
          },
        ),
      ),
    );
  }

  Widget _pageView({
    required double scale,
    required Widget budgetChild,
    required Widget selectionChild,
  }) {
    return PageView(
      clipBehavior: Clip.none,
      padEnds: false,
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentPage = index),
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: (_currentPage == 0 ? HomeCarouselCard.activePageMargin : 0) *
                scale,
            right: HomeCarouselCard.pageGap * scale,
          ),
          child: HomeCarouselCard(
            pageIndex: 0,
            currentPage: _currentPage,
            pageCount: 2,
            child: budgetChild,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: HomeCarouselCard.pageGap * scale,
            right: (_currentPage == 1 ? HomeCarouselCard.activePageMargin : 0) *
                scale,
          ),
          child: HomeCarouselCard(
            pageIndex: 1,
            currentPage: _currentPage,
            pageCount: 2,
            child: selectionChild,
          ),
        ),
      ],
    );
  }

  Widget _cardLoading(double scale) {
    return Center(
      child: SizedBox(
        width: 28 * scale,
        height: 28 * scale,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _cardError(double scale, String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Pretendard',
          color: const Color(0xFF555555),
          fontSize: 12 * scale,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
