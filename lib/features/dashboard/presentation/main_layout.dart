import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/animations/animation_modules.dart';
import 'package:flutter/services.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/haptics_engine.dart';
import 'home_screen.dart';
import '../../tools/presentation/tools_grid_screen.dart';
import '../../device_info/presentation/settings_screen.dart';
import '../../device_info/presentation/device_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _scaleAnims;
  late List<Animation<double>> _slideAnims;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onTabSelected: (index) {
          setState(() => _currentIndex = index);
          _animateTo(index);
        },
      ),
      const ToolsGridScreen(),
      const DeviceScreen(),
      const SettingsScreen(),
    ];

    _iconControllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );

    _scaleAnims = _iconControllers
        .map((c) => TweenSequence<double>([
              TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
              TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
            ]).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();

    _slideAnims = _iconControllers
        .map((c) => TweenSequence<double>([
              TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 50),
              TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 50),
            ]).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();

    // Animate the first tab on launch
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _iconControllers[0].forward(from: 0);
    });
  }

  @override
  void dispose() {
    for (final c in _iconControllers) {
      c.dispose();
    }

    super.dispose();
  }

  void _animateTo(int index) {
    _iconControllers[index].forward(from: 0);
  }

  void _onNavTap(int index) async {
    if (_currentIndex != index) {
      HapticsEngine.selectionClick();
      setState(() => _currentIndex = index);
      _animateTo(index);
    }
  }

  Future<bool> _onWillPop() async {
    HapticsEngine.heavyImpact();

    final shouldPop = await showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            // Blurred overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.black.withOpacity(0.1) 
                    : Colors.white.withOpacity(0.15)),
              ),
            ),
            // Dialog card
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0EBFF), Color(0xFFE8DFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFF8B3DFF).withOpacity(0.25), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B3DFF).withOpacity(0.25),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Leaf left
                      Positioned(
                        bottom: 56,
                        left: -2,
                        child: _LeafDecoration(flip: false),
                      ),
                      // Leaf right
                      Positioned(
                        bottom: 56,
                        right: -2,
                        child: _LeafDecoration(flip: true),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon with sparkles
                            Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDDD5FF),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF8B3DFF).withOpacity(0.2), width: 1),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.login_rounded, color: Color(0xFF6B2DDF), size: 32),
                                  ),
                                ),
                                // Sparkle top-right
                                Positioned(
                                  top: -4,
                                  right: -6,
                                  child: Icon(Icons.auto_awesome, size: 14, color: const Color(0xFF8B3DFF).withOpacity(0.7)),
                                ),
                                // Sparkle bottom-left
                                Positioned(
                                  bottom: 0,
                                  left: -8,
                                  child: Icon(Icons.auto_awesome, size: 10, color: const Color(0xFF8B3DFF).withOpacity(0.5)),
                                ),
                              ],
                            ).applyMicroPop(delay: 80),
                            const SizedBox(height: 18),
                            const Text(
                              'Are you sure?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A0A3D),
                              ),
                            ).applyPremiumFade(delay: 120),
                            const SizedBox(height: 8),
                            const Text(
                              'Do you really want to\nexit the application?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7B6B9D),
                                height: 1.4,
                              ),
                            ).applyPremiumFade(delay: 150),
                            const SizedBox(height: 20),
                            // Safety note
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDE8FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B3DFF).withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.verified_user_rounded, color: Color(0xFF8B3DFF), size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  const Flexible(
                                    child: Text(
                                      'Your data is safe and will\nbe available next time.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B5B95),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).applyPremiumFade(delay: 180),
                            const SizedBox(height: 24),
                            // Buttons
                            Row(
                              children: [
                                // Cancel
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticsEngine.selectionClick();
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(26),
                                        border: Border.all(color: const Color(0xFFD6CCEE), width: 1.5),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF5B4A80),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Exit
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticsEngine.selectionClick();
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF8B3DFF), Color(0xFF5E2BFF)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(26),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF8B3DFF).withOpacity(0.45),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Exit',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.login_rounded, color: Colors.white, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ).applyPremiumFade(delay: 220),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).applyMicroPop(delay: 40),
              ),
            ),
          ],
        );
      },
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;
    
    final overlayStyle = isDarkNow
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          );
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final selectedColor = Theme.of(context).primaryColor;
    final unselectedColor = isDarkNow ? const Color(0xFF5A5A6E) : Colors.grey.shade400;

    final items = [
      _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
      _NavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Tools'),
      _NavItem(Icons.phone_android_outlined, Icons.phone_android_rounded, 'Device'),
      _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (_currentIndex != 0) {
            _onNavTap(0);
          } else {
            final shouldExit = await _onWillPop();
            if (shouldExit) {
              SystemNavigator.pop();
            }
          }
        },
        child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        backgroundColor: bgColor,
        body: Stack(
          children: [
            SlideIndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(top: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkNow ? 0.3 : 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(items.length, (i) {
                        final isSelected = _currentIndex == i;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _onNavTap(i),
                            child: AnimatedBuilder(
                              animation: _iconControllers[i],
                              builder: (ctx, _) {
                                return Transform.translate(
                                  offset: Offset(0, _slideAnims[i].value),
                                  child: Transform.scale(
                                    scale: isSelected ? _scaleAnims[i].value : 1.0,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? selectedColor.withOpacity(0.12)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            isSelected ? items[i].activeIcon : items[i].icon,
                                            color: isSelected ? selectedColor : unselectedColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                            color: isSelected ? selectedColor : unselectedColor,
                                          ),
                                          child: Text(items[i].label),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

/// Decorative leaf widget for the exit dialog
class _LeafDecoration extends StatelessWidget {
  final bool flip;
  const _LeafDecoration({required this.flip});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: Opacity(
        opacity: 0.45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _leafBranch(20, 0),
            _leafBranch(28, 4),
            _leafBranch(22, 8),
          ],
        ),
      ),
    );
  }

  Widget _leafBranch(double width, double leftPad) {
    return Padding(
      padding: EdgeInsets.only(left: leftPad, bottom: 2),
      child: Container(
        width: width,
        height: 8,
        decoration: BoxDecoration(
          color: const Color(0xFF8B3DFF).withOpacity(0.35),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class SlideIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const SlideIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<SlideIndexedStack> createState() => _SlideIndexedStackState();
}

class _SlideIndexedStackState extends State<SlideIndexedStack> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.index;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward(from: 1.0);
  }

  @override
  void didUpdateWidget(SlideIndexedStack oldWidget) {
    if (widget.index != oldWidget.index) {
      _lastIndex = oldWidget.index;
      _controller.forward(from: 0.0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        bool isForward = widget.index > _lastIndex;
        double offset = 1.0 - _controller.value;
        if (!isForward) offset = -offset;

        return Stack(
          children: List.generate(widget.children.length, (i) {
            if (i != widget.index && i != _lastIndex) return const SizedBox.shrink();

            double currentOffset = 0.0;
            if (i == widget.index) {
              currentOffset = offset;
            } else if (i == _lastIndex) {
              currentOffset = isForward ? -_controller.value : _controller.value;
            }

            return FractionalTranslation(
              translation: Offset(currentOffset, 0),
              child: Offstage(
                offstage: i != widget.index && !(i == _lastIndex && _controller.isAnimating),
                child: widget.children[i],
              ),
            );
          }),
        );
      },
    );
  }
}
