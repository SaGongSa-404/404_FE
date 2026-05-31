import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class CircleIconLabel extends StatefulWidget {
  const CircleIconLabel({
    super.key,
    required this.backgroundColor,
    required this.pressedBackgroundColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
    this.onTap,
    this.diameter = 72,
    this.iconSize = 34,
    this.labelFontSize = 12,
  });

  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final VoidCallback? onTap;

  final double diameter;
  final double iconSize;
  final double labelFontSize;

  @override
  State<CircleIconLabel> createState() => _CircleIconLabelFabState();
}

class _CircleIconLabelFabState extends State<CircleIconLabel> {
  static const double _contentNudgeY = -4;

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final diameter = widget.diameter * scale;
    final iconSize = widget.iconSize * scale;
    final labelFontSize = widget.labelFontSize * scale;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: Material(
        color: _pressed ? widget.pressedBackgroundColor : widget.backgroundColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: widget.onTap,
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Center(
              child: Transform.translate(
                offset: Offset(0, _contentNudgeY * scale),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: iconSize,
                        color: widget.iconColor,
                        weight: 650,
                        grade: 25,
                      ),
                      Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        strutStyle: StrutStyle(
                          fontSize: labelFontSize,
                          height: 1.15,
                          fontWeight: FontWeight.w600,
                          leading: 0,
                          forceStrutHeight: true,
                        ),
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          color: widget.labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
