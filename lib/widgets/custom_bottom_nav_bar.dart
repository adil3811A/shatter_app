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
  double _dragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    const double capsuleSize = 52.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double itemWidth = totalWidth / 4;
        final double minPos = (itemWidth - capsuleSize) / 2;
        final double maxPos = 3 * itemWidth + minPos;

        // Calculate current page offset (dragging vs pageController-driven)
        double page = widget.currentIndex.toDouble();
        if (_isDragging) {
          page = (_dragPosition - minPos) / itemWidth;
        } else if (widget.pageController.hasClients && widget.pageController.position.hasContentDimensions) {
          page = widget.pageController.page ?? widget.currentIndex.toDouble();
        }

        final double leftPosition = _isDragging 
            ? _dragPosition 
            : (page * itemWidth + minPos);

        return GestureDetector(
          // Intercept horizontal drag gestures on the entire bottom bar
          onHorizontalDragStart: (details) {
            setState(() {
              _isDragging = true;
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
              
              // Scroll the PageView in sync with the drag position
              if (widget.pageController.hasClients) {
                final double dragPage = (_dragPosition - minPos) / itemWidth;
                final double screenWidth = MediaQuery.of(context).size.width;
                widget.pageController.jumpTo(dragPage * screenWidth);
              }
            });
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              _isDragging = false;
              // Snap to the closest tab index upon release
              final double normalized = (_dragPosition - minPos) / itemWidth;
              final int targetIndex = normalized.round().clamp(0, 3);
              widget.onTap(targetIndex);
            });
          },
          child: Container(
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFF161320), // Dark background matching screenshot
              borderRadius: BorderRadius.circular(42),
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
                // Sliding active indicator capsule (background of the icon)
                Positioned(
                  left: leftPosition,
                  top: 10, // Vertically centered with the icons
                  child: Container(
                    width: capsuleSize,
                    height: capsuleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3B2F57), // Deep purple/violet capsule
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6D28D9).withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // Items Row
                Row(
                  children: List.generate(4, (index) {
                    // Calculate how close the indicator is to this tab (0.0 to 1.0)
                    final double distance = (page - index).abs();
                    final double activeProgress = (1.0 - distance).clamp(0.0, 1.0);

                    // Color interpolation based on indicator proximity
                    final Color iconColor = Color.lerp(
                      const Color(0xFF7C758E), // Inactive grey-purple
                      Colors.white,           // Active white
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
                          if (!_isDragging) {
                            widget.onTap(index);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: capsuleSize,
                              height: capsuleSize,
                              alignment: Alignment.center,
                              child: _buildIconForIndex(index, iconColor, activeProgress),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getLabelForIndex(index),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 11,
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
  }

  Widget _buildIconForIndex(int index, Color color, double activeProgress) {
    switch (index) {
      case 0:
        return Icon(
          Icons.chat_bubble_outline_rounded,
          color: color,
          size: 24,
        );
      case 1:
        return Icon(
          Icons.account_circle_outlined,
          color: color,
          size: 25,
        );
      case 2:
        return Icon(
          Icons.settings_outlined,
          color: color,
          size: 24,
        );
      case 3:
      default:
        // Stylized Profile Icon representing the letter Z inside a circle
        return Opacity(
          opacity: 0.6 + (0.4 * activeProgress),
          child: Container(
            width: 23,
            height: 23,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF8B5CF6), // Violet brand logo background
            ),
            alignment: Alignment.center,
            child: const Text(
              'Z',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1.1,
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
