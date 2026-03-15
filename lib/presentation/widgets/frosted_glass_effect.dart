import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Custom frosted glass effect widget for UI elements
/// Creates realistic glass droplet effects with GPU-accelerated shaders

class FrostedGlassSettings {
  final double blendPx;
  final double refractStrength;
  final double distortFalloffPx;
  final double distortExponent;
  final double blurRadiusPx;
  
  final double specAngle;
  final double specStrength;
  final double specPower;
  final double specWidth;
  
  final double lightbandOffsetPx;
  final double lightbandWidthPx;
  final double lightbandStrength;
  final Color lightbandColor;

  const FrostedGlassSettings({
    this.blendPx = 5,
    this.refractStrength = -0.06,
    this.distortFalloffPx = 45,
    this.distortExponent = 4,
    this.blurRadiusPx = 0,

    this.specAngle = 4,
    this.specStrength = 20.0,
    this.specPower = 100,
    this.specWidth = 10,

    this.lightbandOffsetPx = 10,
    this.lightbandWidthPx = 30,
    this.lightbandStrength = 0.9,
    this.lightbandColor = Colors.white,
  });

  FrostedGlassSettings copyWith({
    double? blendPx,
    double? refractStrength,
    double? distortFalloffPx,
    double? distortExponent,
    double? blurRadiusPx,

    double? specAngle,
    double? specStrength,
    double? specPower,
    double? specWidth,

    double? lightbandOffsetPx,
    double? lightbandWidthPx,
    double? lightbandStrength,
    Color? lightbandColor,
  }) {
    return FrostedGlassSettings(
      blendPx: blendPx ?? this.blendPx,
      refractStrength: refractStrength ?? this.refractStrength,
      distortFalloffPx: distortFalloffPx ?? this.distortFalloffPx,
      distortExponent: distortExponent ?? this.distortExponent,
      blurRadiusPx: blurRadiusPx ?? this.blurRadiusPx,

      specAngle: specAngle ?? this.specAngle,
      specStrength: specStrength ?? this.specStrength,
      specPower: specPower ?? this.specPower,
      specWidth: specWidth ?? this.specWidth,

      lightbandOffsetPx: lightbandOffsetPx ?? this.lightbandOffsetPx,
      lightbandWidthPx: lightbandWidthPx ?? this.lightbandWidthPx,
      lightbandStrength: lightbandStrength ?? this.lightbandStrength,
      lightbandColor: lightbandColor ?? this.lightbandColor,
    );
  }
}

class _ShapeData {
  final Offset center;
  final Size size;
  final double borderRadius;
  final Color color;
  _ShapeData(this.center, this.size, this.borderRadius, this.color);
}

class FrostedGlassGroup extends StatefulWidget {
  final FrostedGlassSettings settings;
  final Listenable? repaint;
  final Widget child;

  const FrostedGlassGroup({
    super.key,
    required this.settings,
    required this.child,
    this.repaint,
  });

  @override
  State<FrostedGlassGroup> createState() => _FrostedGlassGroupState();
}

class _FrostedGlassGroupState extends State<FrostedGlassGroup> {
  FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    FragmentProgram.fromAsset(
      'assets/shaders/frosted_glass.frag',
    ).then((p) => setState(() => _program = p));
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) {
      return widget.child;
    }
    return _FrostedGlassGroupRenderObject(
      shader: _program!.fragmentShader(),
      settings: widget.settings,
      repaint: widget.repaint,
      child: widget.child,
    );
  }
}

class _FrostedGlassGroupRenderObject extends SingleChildRenderObjectWidget {
  final FragmentShader shader;
  final FrostedGlassSettings settings;
  final Listenable? repaint;

  const _FrostedGlassGroupRenderObject({
    required this.shader,
    required this.settings,
    this.repaint,
    super.child,
  });

  @override
  _RenderFrostedGlassGroup createRenderObject(BuildContext context) {
    final position = Scrollable.maybeOf(context)?.position;
    final renderObject = _RenderFrostedGlassGroup(
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      shader: shader,
      settings: settings,
      position: position,
      externalRepaint: repaint,
    );

    _attachRouteAnimation(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFrostedGlassGroup renderObject,
  ) {
    final position = Scrollable.maybeOf(context)?.position;
    renderObject
      ..devicePixelRatio = MediaQuery.of(context).devicePixelRatio
      ..settings = settings
      ..scrollPosition = position
      ..externalRepaint = repaint;

    _attachRouteAnimation(context, renderObject);
  }

  void _attachRouteAnimation(BuildContext ctx, _RenderFrostedGlassGroup rb) {
    final List<Listenable> listenables = [];

    final rLocal = ModalRoute.of(ctx);
    if (rLocal?.animation != null) {
      listenables.add(rLocal!.animation!);
    }
    if (rLocal?.secondaryAnimation != null) {
      listenables.add(rLocal!.secondaryAnimation!);
    }

    final rootNav = Navigator.maybeOf(ctx);
    if (rootNav != null) {
      final rRoot = ModalRoute.of(rootNav.context);
      if (rRoot?.animation != null) {
        listenables.add(rRoot!.animation!);
      }
      if (rRoot?.secondaryAnimation != null) {
        listenables.add(rRoot!.secondaryAnimation!);
      }
    }

    final mergedRouteAnimations = listenables.isNotEmpty 
        ? Listenable.merge(listenables) 
        : null;

    rb.setRouteAnimations(mergedRouteAnimations);
  }

  @override
  void didUnmountRenderObject(_RenderFrostedGlassGroup rb) {
    rb.detachRepaintSources();
  }
}

class _RenderFrostedGlassGroup extends RenderProxyBox {
  static const int maxRects = 4;

  Listenable? _routeAnimations;
  ScrollPosition? _scrollPosition;
  Listenable? _externalRepaint;

  _RenderFrostedGlassGroup({
    required double devicePixelRatio,
    required FragmentShader shader,
    required FrostedGlassSettings settings,
    
    ScrollPosition? position,
    Listenable? externalRepaint,
  }) : _devicePixelRatio = devicePixelRatio,
        _shader = shader,
        _settings = settings,
        _scrollPosition = position,
        _externalRepaint = externalRepaint
  {
    _scrollPosition?.addListener(_onScroll);
    _externalRepaint?.addListener(markNeedsPaint);
  }

  set externalRepaint(Listenable? v) {
    if (identical(v, _externalRepaint)) return;
    _externalRepaint?.removeListener(markNeedsPaint);
    _externalRepaint = v;
    _externalRepaint?.addListener(markNeedsPaint);
  }

  set scrollPosition(ScrollPosition? value) {
    if (value == _scrollPosition) return;
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = value;
    _scrollPosition?.addListener(_onScroll);
    markNeedsPaint();
  }

  void _onScroll() => markNeedsPaint();

  double _devicePixelRatio;
  set devicePixelRatio(double v) {
    if (_devicePixelRatio == v) return;
    _devicePixelRatio = v;
    markNeedsPaint();
  }

  FrostedGlassSettings _settings;
  set settings(FrostedGlassSettings v) {
    _settings = v;
    markNeedsPaint();
  }

  final FragmentShader _shader;
  final Set<RenderFrostedGlass> registeredShapes = {};

  void setRouteAnimations(Listenable? routeAnimations) {
    _routeAnimations?.removeListener(markNeedsPaint);
    _routeAnimations = routeAnimations;
    _routeAnimations?.addListener(markNeedsPaint);
  }

  void detachRepaintSources() {
    _routeAnimations?.removeListener(markNeedsPaint);
    _routeAnimations = null;
    _scrollPosition?.removeListener(_onScroll);
    _externalRepaint?.removeListener(markNeedsPaint);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    markNeedsPaint();
  }

  @override
  void detach() {
    detachRepaintSources();
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final shapes = <_ShapeData>[];
    for (var shape in registeredShapes) {
      if (!shape.attached || shape.size.isEmpty) continue;
      
      final transform = shape.getTransformTo(null);
      final rect = MatrixUtils.transformRect(
        transform,
        Offset.zero & shape.size,
      );
      
      final maxRadius = (rect.size.width < rect.size.height 
          ? rect.size.width 
          : rect.size.height) / 2;
      final clampedRadius = shape.borderRadius > maxRadius 
          ? maxRadius 
          : shape.borderRadius;

      shapes.add(_ShapeData(rect.center, rect.size, clampedRadius, shape.color));
    }

    if (!ImageFilter.isShaderFilterSupported || shapes.isEmpty) {
      super.paint(context, offset);
      return;
    }

    final boundaryTransform = getTransformTo(null);
    final boundary = MatrixUtils.transformRect(
      boundaryTransform,
      Offset.zero & size,
    );

    final sh = _shader;
    
    // Shader Uniform index management
    // We must match exactly what frosted_glass.frag expects
    
    sh.setFloat(0, size.width * _devicePixelRatio);
    sh.setFloat(1, size.height * _devicePixelRatio);
    
    var idx = 2;

    sh
      ..setFloat(idx++, boundary.left * _devicePixelRatio)
      ..setFloat(idx++, boundary.top * _devicePixelRatio)
      ..setFloat(idx++, boundary.right * _devicePixelRatio)
      ..setFloat(idx++, boundary.bottom * _devicePixelRatio)
      
      ..setFloat(idx++, _settings.blendPx * _devicePixelRatio)
      ..setFloat(idx++, _settings.refractStrength)
      ..setFloat(idx++, _settings.distortFalloffPx * _devicePixelRatio)
      ..setFloat(idx++, _settings.distortExponent)
      
      ..setFloat(idx++, _settings.blurRadiusPx * _devicePixelRatio)
      
      ..setFloat(idx++, _settings.specAngle)
      ..setFloat(idx++, _settings.specStrength)
      ..setFloat(idx++, _settings.specPower)
      ..setFloat(idx++, _settings.specWidth * _devicePixelRatio)
      
      ..setFloat(idx++, _settings.lightbandOffsetPx * _devicePixelRatio)
      ..setFloat(idx++, _settings.lightbandWidthPx * _devicePixelRatio)
      ..setFloat(idx++, _settings.lightbandStrength)
      ..setFloat(idx++, (_settings.lightbandColor.r * 255.0).round().clamp(0, 255) / 255.0)
      ..setFloat(idx++, (_settings.lightbandColor.g * 255.0).round().clamp(0, 255) / 255.0)
      ..setFloat(idx++, (_settings.lightbandColor.b * 255.0).round().clamp(0, 255) / 255.0)
      
      ..setFloat(idx++, 1.0 * _devicePixelRatio)
      ..setFloat(idx++, shapes.length.toDouble());

    for (var i = 0; i < maxRects; i++) {
      if (i < shapes.length) {
        final s = shapes[i];
        sh
          ..setFloat(idx++, s.center.dx * _devicePixelRatio)
          ..setFloat(idx++, s.center.dy * _devicePixelRatio)
          ..setFloat(idx++, s.size.width * _devicePixelRatio)
          ..setFloat(idx++, s.size.height * _devicePixelRatio)
          ..setFloat(idx++, s.borderRadius * _devicePixelRatio)
          ..setFloat(idx++, (s.color.r * 255.0).round().clamp(0, 255) / 255.0)
          ..setFloat(idx++, (s.color.g * 255.0).round().clamp(0, 255) / 255.0)
          ..setFloat(idx++, (s.color.b * 255.0).round().clamp(0, 255) / 255.0)
          ..setFloat(idx++, s.color.a);
      } else {
        // Fill remaining rect slots with zeros to avoid garbage data
        sh
          ..setFloat(idx++, 0.0)
          ..setFloat(idx++, 0.0)
          ..setFloat(idx++, 0.0)
          ..setFloat(idx++, 0.0)
          ..setFloat(idx++, 0.0)
          ..setFloat(idx++, 0.0)
          ..setFloat(idx++, 0.0)
          ..setFloat(idx++, 0.0)
          ..setFloat(idx++, 0.0);
      }
    }

    context.pushLayer(
      BackdropFilterLayer(
        filter: ImageFilter.shader(sh),
      ),
      super.paint,
      offset,
    );
  }
}

class FrostedGlass extends SingleChildRenderObjectWidget {
  final bool enabled;
  final double? width;
  final double? height;
  final Color color;
  final double borderRadius;
  final BoxShadow? shadow;
  
  const FrostedGlass({
    super.key,
    this.enabled = true,
    this.width,
    this.height,
    this.color = Colors.transparent,
    this.borderRadius = 0.0,
    this.shadow,
    super.child
  });

  @override
  createRenderObject(BuildContext context) =>
      RenderFrostedGlass(enabled, borderRadius, color);

  @override
  void updateRenderObject(BuildContext context, RenderFrostedGlass renderObject) {
    renderObject
      ..enabled = enabled
      ..color = color
      ..borderRadius = borderRadius;
  }

  @override
  Widget? get child {
    final shadow = this.shadow != null
        ? this.shadow?.copyWith(
              blurStyle: BlurStyle.outer,
              offset: const Offset(0, 0),
            )
        : this.shadow;

    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadow != null ? [shadow] : null,
        ),
        child: super.child);
  }
}

class RenderFrostedGlass extends RenderProxyBox {
  bool _enabled;
  double _borderRadius;
  Color _color;

  RenderFrostedGlass(this._enabled, this._borderRadius, this._color);

  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    
    final layer = _findLayer();
    if (layer != null) {
      if (_enabled) {
        layer.registeredShapes.add(this);
      } else {
        layer.registeredShapes.remove(this);
      }
      layer.markNeedsPaint();
    }
  }

  double get borderRadius => _borderRadius;
  set borderRadius(double value) {
    if (_borderRadius == value) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_enabled) {
      _findLayer()?.registeredShapes.add(this);
    }
  }

  @override
  void detach() {
    _findLayer()?.registeredShapes.remove(this);
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => _enabled;

  _RenderFrostedGlassGroup? _findLayer() {
    var pr = parent;
    while (pr != null && pr is! _RenderFrostedGlassGroup) {
      pr = pr.parent;
    }
    return pr as _RenderFrostedGlassGroup?;
  }
}
