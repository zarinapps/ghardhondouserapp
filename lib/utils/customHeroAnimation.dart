import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class CustomImageHeroAnimation extends StatefulWidget {
  const CustomImageHeroAnimation({
    required this.child,
    required this.type,
    super.key,
    this.image,
  });
  final Widget child;
  final CImageType type;
  final dynamic image;

  @override
  State<CustomImageHeroAnimation> createState() =>
      _CustomImageHeroAnimationState();
}

class _CustomImageHeroAnimationState extends State<CustomImageHeroAnimation> {
  final GlobalKey _key = GlobalKey();

  Map<String, double> _getWidgetInfo(BuildContext context, GlobalKey key) {
    final renderBox = key.currentContext!.findRenderObject()! as RenderBox;

    final size = renderBox.size; // or _widgetKey.currentContext?.size

    final offset = renderBox.localToGlobal(Offset.zero);

    return {
      'x': offset.dx,
      'y': offset.dy,
      'width': size.width,
      'height': size.height,
      'offX': offset.dx,
      'offY': offset.dy,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final targetWidgetInfo = _getWidgetInfo(context, _key);

        Navigator.push(
          context,
          BlurredRouter(
            builder: (context) {
              return _CustomHeroDestinationScreen(
                renderWidgetData: targetWidgetInfo,
                type: widget.type,
                image: widget.image,
              );
            },
            barrierDismiss: true,
          ),
        );
      },
      child: Container(
        key: _key,
        child: widget.child,
      ),
    );
  }
}

enum CImageType { Asset, Network, File, Memory }

class _CustomHeroDestinationScreen extends StatefulWidget {
  const _CustomHeroDestinationScreen({
    required this.renderWidgetData,
    required this.type,
    this.image,
  });
  final Map<String, dynamic> renderWidgetData;
  final CImageType type;
  final dynamic image;

  @override
  State<_CustomHeroDestinationScreen> createState() =>
      _CustomHeroDestinationScreenState();
}

class _CustomHeroDestinationScreenState
    extends State<_CustomHeroDestinationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  Animation<Offset>? _sizeTween;
  Animation<Offset>? _positionTween;
  var mediaQuery = Size.zero;
  @override
  void didChangeDependencies() {
    mediaQuery = MediaQuery.of(context).size;

    super.didChangeDependencies();
  }

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        mediaQuery = MediaQuery.of(context).size;
      },
    );

    final width = widget.renderWidgetData['width'] as double? ?? 0;
    final height = widget.renderWidgetData['height'] as double? ?? 0;
    final x = widget.renderWidgetData['x'] as double? ?? 0;
    final y = widget.renderWidgetData['y'] as double? ?? 0;

    _sizeTween =
        Tween(begin: Offset(width, height), end: const Offset(200, 200))
            .animate(_controller);
    Future.delayed(
      Duration.zero,
      () {
        _positionTween = Tween(
          begin: Offset(
            x,
            y,
          ),
          end: Offset(
            (MediaQuery.of(context).size.width / 2) - (200 / 2),
            (MediaQuery.of(context).size.height / 2) - 100,
          ),
        ).animate(_controller);
      },
    );

    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        _controller.forward();
      },
    );

    super.initState();
  }

  ImageProvider imageTypeAdapeter(CImageType type, dynamic image) {
    switch (type) {
      case CImageType.Asset:
        return AssetImage(image?.toString() ?? '');

      case CImageType.Network:
        return NetworkImage(image?.toString() ?? '');

      case CImageType.File:
        return FileImage(image as File? ?? File(''));

      case CImageType.Memory:
        return MemoryImage(image as Uint8List? ?? Uint8List(0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.1),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return InteractiveViewer(
              child: Stack(
                children: [
                  Positioned(
                    left: _positionTween?.value.dx,
                    top: _positionTween?.value.dy,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      width: _sizeTween?.value.dx,
                      height: _sizeTween?.value.dy,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Image(
                        fit: BoxFit.cover,
                        image: imageTypeAdapeter(widget.type, widget.image),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
