import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

enum TransitionType {
  fade('fade'),
  scale('scale'),
  slide('slide'),
  size('size'),
  rotate('rotate'),
  rotationOpacity('rotationOpacity'),
  flip('flip'),
  none('none');

  final String title;

  const TransitionType(this.title);

  static TransitionType? fromTitle(String title) => TransitionType.values.firstWhereOrNull((type) => type.title == title);
}

class TransitionManager {
  final Animation<double> animation;
  final Widget child;

  TransitionManager({required this.animation, required this.child});

  Widget applyTransition(TransitionType? transitionType) {
    switch (transitionType) {
      case TransitionType.none:
        return child;
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case TransitionType.scale:
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case TransitionType.size:
        return SizeTransition(
          sizeFactor: animation,
          child: child,
        );
      case TransitionType.rotate:
        return RotationTransition(
          turns: animation,
          child: child,
        );
      case TransitionType.rotationOpacity:
        return CustomRotationOpacityTransition(animation: animation, child: child);
      case TransitionType.flip:
        return FlipTransition(animation: animation, child: child);
      default:
        return child;
    }
  }
}

class CustomRotationOpacityTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const CustomRotationOpacityTransition({super.key, required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: animation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class FlipTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const FlipTransition({super.key, required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(animation.value * 3.1415);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}
