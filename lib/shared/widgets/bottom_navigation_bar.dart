import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
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
    final scale = responsiveScale(context);
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: _BottomNavBarShadow.layers,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: 18 * scale,
            bottom: 10 * scale,
          ),
          child: Row(
            children: [
              for (var i = 0; i < _paths.length; i++)
                Expanded(
                  child: _BottomNavItem(
                    selected: i == currentIndex,
                    tabIndex: i,
                    label: _labels[i],
                    scale: scale,
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
    required this.scale,
    required this.onTap,
  });

  final bool selected;
  final int tabIndex;
  final String label;
  final double scale;
  final VoidCallback onTap;

  Widget _leadingIcon(Color color) {
    final iconSize = 24 * scale;
    if (tabIndex == 0) {
      return SvgPicture.asset(
        AppBottomNavigationBar._homeSvgAsset,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        theme: SvgTheme(currentColor: color),
      );
    }
    return Icon(
      AppBottomNavigationBar._materialIcons[tabIndex - 1],
      size: iconSize,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brown : const Color(0xFFADADAD);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _leadingIcon(color),
              SizedBox(height: 5 * scale),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
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
