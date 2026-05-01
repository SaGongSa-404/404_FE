import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'package:fe_app/features/onboarding/views/components/onboarding_primary_button.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_progress_indicator.dart';

enum _Stage { playing, playedOnce, withButton }

class WishlistTutorialScreen extends StatefulWidget {
  const WishlistTutorialScreen({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
    required this.label,
    required this.titleWhilePlaying,
    required this.titleAfterPlay,
    required this.videoAsset,
    required this.buttonLabel,
    required this.onComplete,
  });

  final int currentStep;
  final int totalSteps;
  final String label;
  final String titleWhilePlaying;
  final String titleAfterPlay;
  final String videoAsset;
  final String buttonLabel;
  final VoidCallback onComplete;

  @override
  State<WishlistTutorialScreen> createState() =>
      _WishlistTutorialScreenState();
}

class _WishlistTutorialScreenState extends State<WishlistTutorialScreen> {
  static const _designWidth = 412.0;
  static const _buttonAppearDelay = Duration(milliseconds: 800);

  late final VideoPlayerController _controller;
  Timer? _buttonTimer;
  _Stage _stage = _Stage.playing;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..setLooping(false)
      ..setVolume(0)
      ..addListener(_onVideoChanged);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _videoInitialized = true);
      _controller.play();
    });
  }

  @override
  void dispose() {
    _buttonTimer?.cancel();
    _controller.removeListener(_onVideoChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onVideoChanged() {
    if (_stage != _Stage.playing) return;
    final value = _controller.value;
    if (!value.isInitialized) return;
    final ended = value.position >= value.duration && !value.isPlaying;
    if (!ended) return;

    setState(() => _stage = _Stage.playedOnce);
    _buttonTimer = Timer(_buttonAppearDelay, () {
      if (!mounted) return;
      setState(() => _stage = _Stage.withButton);
    });
  }

  String get _title => switch (_stage) {
        _Stage.playing => widget.titleWhilePlaying,
        _ => widget.titleAfterPlay,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                (constraints.maxWidth * (24 / _designWidth)).clamp(20.0, 48.0);
            final innerWidth =
                constraints.maxWidth - (horizontalPadding * 2);
            final videoWidth =
                (innerWidth * 0.87).clamp(260.0, 360.0);
            final videoHeight = videoWidth * (362 / 318);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 30),
                            OnboardingProgressIndicator(
                              currentStep: widget.currentStep,
                              totalSteps: widget.totalSteps,
                              onBack: () => context.canPop()
                                  ? context.pop()
                                  : context.go('/'),
                            ),
                            const Spacer(flex: 108),
                            _StepHeader(
                              label: widget.label,
                              title: _title,
                            ),
                            const SizedBox(height: 45),
                            Center(
                              child: _VideoCard(
                                width: videoWidth,
                                height: videoHeight,
                                controller: _controller,
                                initialized: _videoInitialized,
                              ),
                            ),
                            const Spacer(flex: 60),
                            AnimatedOpacity(
                              opacity:
                                  _stage == _Stage.withButton ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 400),
                              child: IgnorePointer(
                                ignoring: _stage != _Stage.withButton,
                                child: OnboardingPrimaryButton(
                                  label: widget.buttonLabel,
                                  onPressed: widget.onComplete,
                                ),
                              ),
                            ),
                            const Spacer(flex: 75),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.label, required this.title});

  final String label;
  final String title;

  static const _labelColor = Color(0xFF929292);
  static const _titleColor = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.task_alt, size: 24, color: _labelColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _labelColor,
                height: 1.45,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.topLeft,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          child: Text(
            title,
            key: ValueKey(title),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: _titleColor,
              height: 1.36,
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.width,
    required this.height,
    required this.controller,
    required this.initialized,
  });

  final double width;
  final double height;
  final VideoPlayerController controller;
  final bool initialized;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFB2B2B2),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: initialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
            : null,
      ),
    );
  }
}
