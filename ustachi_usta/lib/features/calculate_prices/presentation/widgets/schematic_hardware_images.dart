import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class SchematicHardwareImages {
  const SchematicHardwareImages({
    this.hinge,
    this.handle,
    this.handleRight,
    this.windowHandle,
  });

  final ui.Image? hinge;
  final ui.Image? handle;
  final ui.Image? handleRight;
  final ui.Image? windowHandle;

  bool get isReady =>
      hinge != null &&
      handle != null &&
      handleRight != null &&
      windowHandle != null;

  static const _paths = (
    hinge: 'assets/images/thinder.png',
    handle: 'assets/images/handler.png',
    handleRight: 'assets/images/handler_right.png',
    windowHandle: 'assets/images/window_handler.png',
  );

  static final Map<String, ui.Image> _cache = {};
  static final Map<String, Future<ui.Image>> _pending = {};

  static SchematicHardwareImages get current => SchematicHardwareImages(
        hinge: _cache[_paths.hinge],
        handle: _cache[_paths.handle],
        handleRight: _cache[_paths.handleRight],
        windowHandle: _cache[_paths.windowHandle],
      );

  static Future<SchematicHardwareImages> load() async {
    await Future.wait([
      _fetch(_paths.hinge),
      _fetch(_paths.handle),
      _fetch(_paths.handleRight),
      _fetch(_paths.windowHandle),
    ]);
    return current;
  }

  static Future<ui.Image> _fetch(String path) {
    final cached = _cache[path];
    if (cached != null) return Future.value(cached);
    return _pending[path] ??= () async {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _cache[path] = frame.image;
      return frame.image;
    }();
  }
}

class SchematicHardwareImagesLoader extends StatefulWidget {
  const SchematicHardwareImagesLoader({super.key, required this.builder});

  final Widget Function(BuildContext context, SchematicHardwareImages images)
      builder;

  @override
  State<SchematicHardwareImagesLoader> createState() =>
      _SchematicHardwareImagesLoaderState();
}

class _SchematicHardwareImagesLoaderState
    extends State<SchematicHardwareImagesLoader> {
  SchematicHardwareImages _images = SchematicHardwareImages.current;

  @override
  void initState() {
    super.initState();
    if (!_images.isReady) {
      SchematicHardwareImages.load().then((images) {
        if (mounted) setState(() => _images = images);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _images);
}
