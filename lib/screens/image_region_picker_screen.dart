import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // pure dart image lib

class ImageRegionPickerScreen extends StatefulWidget {
  final String imagePath;

  const ImageRegionPickerScreen({super.key, required this.imagePath});

  @override
  State<ImageRegionPickerScreen> createState() => _ImageRegionPickerScreenState();
}

class _ImageRegionPickerScreenState extends State<ImageRegionPickerScreen> {
  Uint8List? _bytes;
  int? _imgW;
  int? _imgH;

  Rect? _selection; // in container coordinates
  Offset? _dragStart;
  Rect? _imageDisplayedRect; // image rect inside the available container
  _DragMode _dragMode = _DragMode.none;
  Offset? _lastDragPos;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await File(widget.imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像の読み込みに失敗しました')),
      );
      Navigator.pop(context);
      return;
    }
    setState(() {
      _bytes = bytes;
      _imgW = decoded.width;
      _imgH = decoded.height;
    });
  }

  // Map selection (container coords) to original image pixels
  Rect? _mapSelectionToImagePixels(Size containerSize) {
    if (_selection == null || _imgW == null || _imgH == null || _imageDisplayedRect == null) return null;
    final disp = _imageDisplayedRect!; // area showing image within container
    final scale = disp.width / _imgW!; // since BoxFit.contain ensures same scale both axes
    // clamp selection to displayed image rect
    final sel = Rect.fromLTWH(
      math.max(_selection!.left, disp.left),
      math.max(_selection!.top, disp.top),
      math.min(_selection!.right, disp.right) - math.max(_selection!.left, disp.left),
      math.min(_selection!.bottom, disp.bottom) - math.max(_selection!.top, disp.top),
    );
    if (sel.width <= 0 || sel.height <= 0) return null;
    final x = ((sel.left - disp.left) / scale).floor();
    final y = ((sel.top - disp.top) / scale).floor();
    final w = (sel.width / scale).floor();
    final h = (sel.height / scale).floor();
    // ensure within original bounds
    final rx = x.clamp(0, _imgW! - 1);
    final ry = y.clamp(0, _imgH! - 1);
    final rw = w.clamp(1, _imgW! - rx);
    final rh = h.clamp(1, _imgH! - ry);
    return Rect.fromLTWH(rx.toDouble(), ry.toDouble(), rw.toDouble(), rh.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('範囲を選択'),
      ),
      body: _bytes == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final containerSize = Size(constraints.maxWidth, constraints.maxHeight - 80);
                // compute displayed image rect (BoxFit.contain)
                final iw = _imgW!.toDouble();
                final ih = _imgH!.toDouble();
                final scale = math.min(containerSize.width / iw, containerSize.height / ih);
                final dispW = iw * scale;
                final dispH = ih * scale;
                final offsetX = (containerSize.width - dispW) / 2;
                final offsetY = (containerSize.height - dispH) / 2;
                _imageDisplayedRect = Rect.fromLTWH(offsetX, offsetY, dispW, dispH);

                return Column(
                  children: [
                    SizedBox(
                      width: containerSize.width,
                      height: containerSize.height,
                      child: Stack(
                        children: [
                          Positioned(
                            left: offsetX,
                            top: offsetY,
                            width: dispW,
                            height: dispH,
                            child: Image.memory(
                              _bytes!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned.fill(
                            child: GestureDetector(
                              onPanStart: (d) {
                                setState(() {
                                  _dragStart = d.localPosition;
                                  _lastDragPos = d.localPosition;
                                  _dragMode = _decideDragMode(d.localPosition);
                                  if (_dragMode == _DragMode.newRect) {
                                    _selection = Rect.fromLTWH(_dragStart!.dx, _dragStart!.dy, 0, 0);
                                  }
                                });
                              },
                              onPanUpdate: (d) {
                                setState(() {
                                  final cur = d.localPosition;
                                  final bounds = _imageDisplayedRect ?? (Offset.zero & containerSize);
                                  switch (_dragMode) {
                                    case _DragMode.newRect:
                                      final left = math.min(_dragStart!.dx, cur.dx);
                                      final top = math.min(_dragStart!.dy, cur.dy);
                                      final right = math.max(_dragStart!.dx, cur.dx);
                                      final bottom = math.max(_dragStart!.dy, cur.dy);
                                      _selection = _clampRect(Rect.fromLTRB(left, top, right, bottom), bounds);
                                      break;
                                    case _DragMode.move:
                                      if (_selection != null && _lastDragPos != null) {
                                        final dx = cur.dx - _lastDragPos!.dx;
                                        final dy = cur.dy - _lastDragPos!.dy;
                                        _selection = _clampRect(_selection!.shift(Offset(dx, dy)), bounds);
                                      }
                                      break;
                                    case _DragMode.resizeLeft:
                                    case _DragMode.resizeRight:
                                    case _DragMode.resizeTop:
                                    case _DragMode.resizeBottom:
                                    case _DragMode.resizeNW:
                                    case _DragMode.resizeNE:
                                    case _DragMode.resizeSW:
                                    case _DragMode.resizeSE:
                                      if (_selection != null) {
                                        _selection = _resizeSelection(_selection!, cur, _dragMode, bounds);
                                      }
                                      break;
                                    case _DragMode.none:
                                      break;
                                  }
                                  _lastDragPos = cur;
                                });
                              },
                              onPanEnd: (_) {
                                setState(() {
                                  _dragStart = null;
                                  _lastDragPos = null;
                                  _dragMode = _DragMode.none;
                                });
                              },
                              child: CustomPaint(
                                painter: _RegionPainter(selection: _selection),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() => _selection = null),
                              icon: const Icon(Icons.crop_free),
                              label: const Text('やり直す'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                final mapped = _mapSelectionToImagePixels(containerSize);
                                if (mapped == null || mapped.width < 4 || mapped.height < 4) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('有効な範囲を選択してください')),
                                  );
                                  return;
                                }
                                // Crop and return bytes for OCR
                                try {
                                  final decoded = img.decodeImage(_bytes!);
                                  if (decoded == null) throw Exception('decode failed');
                                  final crop = img.copyCrop(
                                    decoded,
                                    x: mapped.left.toInt(),
                                    y: mapped.top.toInt(),
                                    width: mapped.width.toInt(),
                                    height: mapped.height.toInt(),
                                  );
                                  final outBytes = Uint8List.fromList(img.encodePng(crop));
                                  Navigator.pop(context, outBytes);
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('切り出しに失敗しました: $e')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('この範囲をOCR'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
    );
  }
}

class _RegionPainter extends CustomPainter {
  final Rect? selection;
  _RegionPainter({this.selection});

  @override
  void paint(Canvas canvas, Size size) {
    if (selection == null) return;
    final rect = selection!;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.redAccent;
    final shade = Paint()
      ..color = Colors.black.withOpacity(0.2);

    // shaded outside
    final full = Path()..addRect(Offset.zero & size);
    final sel = Path()..addRect(rect);
    final diff = Path.combine(PathOperation.difference, full, sel);
    canvas.drawPath(diff, shade);

    // border
    canvas.drawRect(rect, paint);

    // corner handles
    const hs = 8.0;
    final handles = <Offset>[
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ];
    final hPaint = Paint()..color = Colors.redAccent;
    for (final o in handles) {
      canvas.drawRect(Rect.fromCenter(center: o, width: hs * 2, height: hs * 2), hPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RegionPainter oldDelegate) => oldDelegate.selection != selection;
}

enum _DragMode {
  none,
  newRect,
  move,
  resizeLeft,
  resizeRight,
  resizeTop,
  resizeBottom,
  resizeNW,
  resizeNE,
  resizeSW,
  resizeSE,
}

Rect _clampRect(Rect r, Rect bounds) {
  double left = r.left.clamp(bounds.left, bounds.right - 1);
  double top = r.top.clamp(bounds.top, bounds.bottom - 1);
  double right = r.right.clamp(bounds.left + 1, bounds.right);
  double bottom = r.bottom.clamp(bounds.top + 1, bounds.bottom);
  if (right < left + 1) right = left + 1;
  if (bottom < top + 1) bottom = top + 1;
  return Rect.fromLTRB(left, top, right, bottom);
}

extension on _ImageRegionPickerScreenState {
  static const double _hit = 16; // px

  _DragMode _decideDragMode(Offset p) {
    final rect = _selection;
    final bounds = _imageDisplayedRect;
    if (rect == null || bounds == null || !_pointInRect(p, bounds)) {
      return _DragMode.newRect;
    }
    if (_pointInRect(p, rect)) {
      // near corners?
      final tl = rect.topLeft;
      final tr = rect.topRight;
      final bl = rect.bottomLeft;
      final br = rect.bottomRight;
      if (_near(p, tl)) return _DragMode.resizeNW;
      if (_near(p, tr)) return _DragMode.resizeNE;
      if (_near(p, bl)) return _DragMode.resizeSW;
      if (_near(p, br)) return _DragMode.resizeSE;
      // near edges?
      if ((p.dx - rect.left).abs() <= _hit) return _DragMode.resizeLeft;
      if ((p.dx - rect.right).abs() <= _hit) return _DragMode.resizeRight;
      if ((p.dy - rect.top).abs() <= _hit) return _DragMode.resizeTop;
      if ((p.dy - rect.bottom).abs() <= _hit) return _DragMode.resizeBottom;
      return _DragMode.move;
    }
    // clicked outside but in bounds -> new rect
    return _DragMode.newRect;
  }

  bool _near(Offset a, Offset b) => (a - b).distance <= _hit * 1.2;
  bool _pointInRect(Offset p, Rect r) => p.dx >= r.left && p.dx <= r.right && p.dy >= r.top && p.dy <= r.bottom;

  Rect _resizeSelection(Rect r, Offset p, _DragMode m, Rect bounds) {
    double left = r.left, right = r.right, top = r.top, bottom = r.bottom;
    switch (m) {
      case _DragMode.resizeLeft:
        left = p.dx;
        break;
      case _DragMode.resizeRight:
        right = p.dx;
        break;
      case _DragMode.resizeTop:
        top = p.dy;
        break;
      case _DragMode.resizeBottom:
        bottom = p.dy;
        break;
      case _DragMode.resizeNW:
        left = p.dx; top = p.dy;
        break;
      case _DragMode.resizeNE:
        right = p.dx; top = p.dy;
        break;
      case _DragMode.resizeSW:
        left = p.dx; bottom = p.dy;
        break;
      case _DragMode.resizeSE:
        right = p.dx; bottom = p.dy;
        break;
      default:
        break;
    }
    // ensure min size
    if (right < left + 1) right = left + 1;
    if (bottom < top + 1) bottom = top + 1;
    return _clampRect(Rect.fromLTRB(left, top, right, bottom), bounds);
  }
}
