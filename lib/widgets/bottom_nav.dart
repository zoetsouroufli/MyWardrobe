import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousIndex = 0;
  double _currentPosition = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    // Initialize position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentPosition = _getIndicatorPosition(widget.selectedIndex);
        });
      }
    });
  }

  @override
  void didUpdateWidget(BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      setState(() {
        _previousIndex = oldWidget.selectedIndex;
        _currentPosition = _getIndicatorPosition(widget.selectedIndex);
      });
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getIndicatorPosition(int index) {
    // Calculate position based on screen width divided by 4 icons
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 4;
    // Center the 40px indicator: start of section + half section width - half indicator width
    return (itemWidth * index) + (itemWidth / 2) - 20;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        clipBehavior: Clip.none, // Allow indicator to overflow if needed
        children: [
          // Animated indicator with liquid glass effect
          TweenAnimationBuilder<double>(
            key: ValueKey(widget.selectedIndex),
            tween: Tween<double>(
              begin: _getIndicatorPosition(_previousIndex),
              end: _currentPosition,
            ),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            builder: (context, value, child) {
              return Positioned(
                left: value,
                top: 8,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF9C27B0).withOpacity(0.3),
                        const Color(0xFF9C27B0).withOpacity(0.15),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _icon(Icons.group, 0),
              _icon(Icons.tune, 1),
              _icon(Icons.favorite, 2),
              _icon(Icons.checkroom, 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, int index) {
    final isSelected = widget.selectedIndex == index;
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF9C27B0) : Colors.black54,
          size: isSelected ? 26 : 24,
        ),
      ),
    );
  }
}
