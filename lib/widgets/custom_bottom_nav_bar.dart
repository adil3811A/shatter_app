import 'package:flutter/material.dart';

class ShatterBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final PageController pageController;

  const ShatterBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.pageController,
  });

  @override
  State<ShatterBottomNavBar> createState() => _ShatterBottomNavBarState();
}

class _ShatterBottomNavBarState extends State<ShatterBottomNavBar> {
  bool _isDragging = false;
  bool _isAnimatingToTab = false;
  double _dragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    const double barHeight = 62.0;
    const double capsuleHeight = 46.0;
    const double horizontalMargin = 6.0; // Dynamic margin on each side of the capsule

    final double screenWidth = MediaQuery.of(context).size.width;
    // Account for padding surrounding the bar: 16px on each side (total 32px)
    double barWidth = screenWidth - 32;
    if (barWidth > 400.0) {
      barWidth = 400.0; // Keep it clean and centered on tablets/wide screens
    }

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1.0,
      child: SizedBox(
        width: barWidth,
        child: AnimatedBuilder(
          animation: widget.pageController,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final double totalWidth = constraints.maxWidth;
                final double itemWidth = totalWidth / 4;
                
                // Boundary coordinates for selection capsule
                final double minPos = horizontalMargin;
                final double maxPos = 3 * itemWidth + horizontalMargin;

                // Calculate active page offset (dragging vs pageController-driven)
                final bool useManualPosition = _isDragging || _isAnimatingToTab;
                double page = widget.currentIndex.toDouble();
                if (useManualPosition) {
                  page = (_dragPosition - minPos) / itemWidth;
                } else if (widget.pageController.hasClients && widget.pageController.position.hasContentDimensions) {
                  page = widget.pageController.page ?? widget.currentIndex.toDouble();
                }

                final double leftPosition = useManualPosition 
                    ? _dragPosition 
                    : (page * itemWidth + minPos);

                final double capsuleWidth = itemWidth - (horizontalMargin * 2);

                // Capsule moves instantly when dragging, but snaps/slides quickly when released or page changes
                final Duration animationDuration = _isAnimatingToTab 
                    ? const Duration(milliseconds: 150) 
                    : Duration.zero;

                return GestureDetector(
                  // Intercept horizontal drag gestures on the entire bottom bar
                  onHorizontalDragStart: (details) {
                    setState(() {
                      _isDragging = true;
                      _isAnimatingToTab = false;
                      // Initialize drag position to match the current selection position
                      double currentPage = widget.currentIndex.toDouble();
                      if (widget.pageController.hasClients && widget.pageController.position.hasContentDimensions) {
                        currentPage = widget.pageController.page ?? widget.currentIndex.toDouble();
                      }
                      _dragPosition = currentPage * itemWidth + minPos;
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx).clamp(minPos, maxPos);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    // Calculate snapping index upon release
                    final double normalized = (_dragPosition - minPos) / itemWidth;
                    final int targetIndex = normalized.round().clamp(0, 3);
                    
                    setState(() {
                      _isAnimatingToTab = true;
                      _dragPosition = targetIndex * itemWidth + minPos; // Target snap coordinate
                    });

                    // Trigger screen page animation AFTER the user finishes dragging
                    widget.onTap(targetIndex);

                    // Re-enable pageController-driven tracking after transitions settle (200ms)
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) {
                        setState(() {
                          _isAnimatingToTab = false;
                          _isDragging = false;
                        });
                      }
                    });
                  },
                  child: Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161320), // Dark background matching screenshot
                      borderRadius: BorderRadius.circular(barHeight / 2),
                      border: Border.all(
                        color: const Color(0xFF242038).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Sliding active indicator capsule (background enclosing both icon & text)
                        AnimatedPositioned(
                          duration: animationDuration,
                          curve: Curves.easeOutCubic,
                          left: leftPosition,
                          top: (barHeight - capsuleHeight) / 2, // Centered vertically
                          child: Container(
                            width: capsuleWidth,
                            height: capsuleHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(capsuleHeight / 2),
                              color: const Color(0xFF8B5CF6).withOpacity(0.15), // Translucent violet brand highlight
                              border: Border.all(
                                color: const Color(0xFF8B5CF6).withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                          ),
                        ),

                        // Items Row
                        Row(
                          children: List.generate(4, (index) {
                            // Calculate how close the indicator is to this tab (0.0 to 1.0)
                            final double distance = (page - index).abs();
                            final double activeProgress = (1.0 - distance).clamp(0.0, 1.0);

                            // Interpolate colors: inactive grey-purple to active violet/lavender
                            final Color iconColor = Color.lerp(
                              const Color(0xFF7C758E), // Inactive grey-purple
                              const Color(0xFF8B5CF6), // Active violet
                              activeProgress,
                            )!;

                            final Color textColor = Color.lerp(
                              const Color(0xFF7C758E), // Inactive grey-purple
                              const Color(0xFFD8B4FE), // Active soft lavender
                              activeProgress,
                            )!;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (!_isDragging && !_isAnimatingToTab) {
                                    widget.onTap(index);
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 24, // Reduced icon height boundary
                                      alignment: Alignment.center,
                                      child: _buildIconForIndex(index, iconColor, activeProgress),
                                    ),
                                    const SizedBox(height: 1), // Reduced gap
                                    Text(
                                      _getLabelForIndex(index),
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 10, // Sleeker font size
                                        fontWeight: activeProgress > 0.5
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildIconForIndex(int index, Color color, double activeProgress) {
    // Determine whether to use a filled icon for active or outlined icon for inactive
    final bool isActive = activeProgress > 0.5;

    switch (index) {
      case 0:
        return Icon(
          isActive ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
          color: color,
          size: 20, // Reduced icon size
        );
      case 1:
        return Icon(
          isActive ? Icons.account_circle_rounded : Icons.account_circle_outlined,
          color: color,
          size: 21, // Reduced icon size
        );
      case 2:
        return Icon(
          isActive ? Icons.settings_rounded : Icons.settings_outlined,
          color: color,
          size: 20, // Reduced icon size
        );
      case 3:
      default:
        // Stylized Profile Icon representing the letter Z inside a circle
        // Blend opacity between active and inactive states
        return Opacity(
          opacity: 0.75 + (0.25 * activeProgress),
          child: Container(
            width: 20, // Reduced profile size
            height: 20, // Reduced profile size
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF8B5CF6), // Brand violet logo background matching active theme
            ),
            alignment: Alignment.center,
            child: const Text(
              'z', // Lowercase 'z' as seen in the new screenshot
              style: TextStyle(
                color: Colors.white,
                fontSize: 10, // Sleeker font size
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ),
        );
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Chats';
      case 1:
        return 'Contacts';
      case 2:
        return 'Settings';
      case 3:
      default:
        return 'Profile';
    }
  }
}
