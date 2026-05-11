import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

abstract final class _BottomNavBarShadow {
  static const Color spotAndAmbient = Color(0x40000000);

  static const List<BoxShadow> layers = [
    BoxShadow(
      color: spotAndAmbient,
      offset: Offset(0, 1),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
}

abstract final class _BottomNavTokens {
  static const double barPaddingTop = 18;
  static const double barPaddingBottom = 10;
  static const double tabPaddingHorizontal = 4;
  static const double iconLabelGap = 5;
  static const double labelFontSize = 12;
  static const FontWeight labelFontWeight = FontWeight.w500;
  static const double iconSize = 24;
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  static const _paths = ['/home', '/wishlist', '/profile', '/my'];

  int _currentIndex(String location) {
    if (location.startsWith('/wishlist')) return 1;
    if (location.startsWith('/profile')) return 2;
    if (location.startsWith('/my')) return 3;
    if (location.startsWith('/home')) return 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: _BottomNavBarShadow.layers,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: _BottomNavTokens.barPaddingTop,
            bottom: _BottomNavTokens.barPaddingBottom,
          ),
          child: Row(
            children: [
              for (var i = 0; i < _paths.length; i++)
                Expanded(
                  child: _BottomNavItem(
                    selected: i == currentIndex,
                    tabIndex: i,
                    label: _labels[i],
                    onTap: () => context.go(_paths[i]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static const _labels = ['홈', '위시', '피드', '마이'];

  static const _homeSvgAsset = 'assets/images/home.svg';

  static const _materialIcons = [
    Icons.format_list_bulleted_outlined,
    Icons.group_outlined,
    Icons.person_outlined,
  ];
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.selected,
    required this.tabIndex,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final int tabIndex;
  final String label;
  final VoidCallback onTap;

  Widget _leadingIcon(Color color) {
    if (tabIndex == 0) {
      return SvgPicture.asset(
        AppBottomNavigationBar._homeSvgAsset,
        width: _BottomNavTokens.iconSize,
        height: _BottomNavTokens.iconSize,
        fit: BoxFit.contain,
        theme: SvgTheme(currentColor: color),
      );
    }
    return Icon(
      AppBottomNavigationBar._materialIcons[tabIndex - 1],
      size: _BottomNavTokens.iconSize,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brown : Color(0xFFADADAD);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _BottomNavTokens.tabPaddingHorizontal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _leadingIcon(color),
              SizedBox(height: _BottomNavTokens.iconLabelGap),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: _BottomNavTokens.labelFontSize,
                  fontWeight: _BottomNavTokens.labelFontWeight,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
