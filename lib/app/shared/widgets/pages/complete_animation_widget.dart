import 'package:flutter/material.dart';

class CompletionAnimation extends StatefulWidget {
  final Widget nextPage;

  const CompletionAnimation({super.key, required this.nextPage});

  @override
  _CompletionAnimationState createState() => _CompletionAnimationState();
}

class _CompletionAnimationState extends State<CompletionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => widget.nextPage),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }
}
