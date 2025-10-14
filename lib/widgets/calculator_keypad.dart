import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/keypad_layout_mode.dart';

enum CalculatorKeyType { input, delete, moveLeft, moveRight }

class CalculatorKeyEvent {
  const CalculatorKeyEvent(this.type, [this.value = '']);

  final CalculatorKeyType type;
  final String value;
}

class CalculatorKeypad extends StatefulWidget {
  const CalculatorKeypad({
    super.key,
    required this.onKeyPressed,
    required this.mode,
  });

  final void Function(CalculatorKeyEvent event) onKeyPressed;
  final KeypadLayoutMode mode;

  static const List<_KeyCategory> _categories = [
    _KeyCategory(
      label: 'Num',
      icon: Icons.pin_rounded,
      keys: [
        _KeySpec.input('0'),
        _KeySpec.input('1'),
        _KeySpec.input('2'),
        _KeySpec.input('3'),
        _KeySpec.input('4'),
        _KeySpec.input('5'),
        _KeySpec.input('6'),
        _KeySpec.input('7'),
        _KeySpec.input('8'),
        _KeySpec.input('9'),
        _KeySpec.input('.'),
      ],
    ),
    _KeyCategory(
      label: 'Func',
      icon: Icons.functions_rounded,
      keys: [
        _KeySpec.input('pow(', label: 'x^()'),
        _KeySpec.input('sqrt(', label: '\u221A'),
        _KeySpec.input('cbrt(', label: '\u221B'),
        _KeySpec.input('root(', label: '\u207F\u221A'),
        _KeySpec.input('frac(', label: 'a/b'),
        _KeySpec.input('abs(', label: '|x|'),
        _KeySpec.input('f(', label: 'f(x)'),
        _KeySpec.input('sin('),
        _KeySpec.input('cos('),
        _KeySpec.input('tan('),
        _KeySpec.input('ln('),
        _KeySpec.input('log('),
        _KeySpec.input('n!', label: 'n!'),
      ],
    ),
    _KeyCategory(
      label: 'Adv',
      icon: Icons.science_rounded,
      keys: [
        _KeySpec.input('^', label: 'x^y'),
        _KeySpec.input('sum(', label: '\u03A3'),
        _KeySpec.input('prod(', label: '\u03A0'),
        _KeySpec.input('integral(', label: '\u222B'),
        _KeySpec.input('nPr(', label: 'P'),
        _KeySpec.input('nCr(', label: 'C'),
        _KeySpec.input('Re(', label: 'Re'),
        _KeySpec.input('Im(', label: 'Im'),
        _KeySpec.input('conj(', label: 'z*'),
        _KeySpec.input('|', label: '|'),
      ],
    ),
    _KeyCategory(
      label: 'Var',
      icon: Icons.text_fields_rounded,
      keys: [
        _KeySpec.input('x'),
        _KeySpec.input('y'),
        _KeySpec.input('z'),
        _KeySpec.input('n'),
        _KeySpec.input('pi', label: '\u03C0'),
        _KeySpec.input('e'),
        _KeySpec.input('i'),
      ],
    ),
  ];
  // Frequently used keys displayed below the category shortcuts.
  static const List<_KeySpec> _commonKeys = [
    // Keys originally in the edit category.
    _KeySpec.delete(),
    _KeySpec.moveLeft(),
    _KeySpec.moveRight(),
    // Keys originally in the operations category (except x^y).
    _KeySpec.input('+'),
    _KeySpec.input('-'),
    _KeySpec.input('*', label: '\u00D7'),
    _KeySpec.input('/', label: '\u00F7'),
    _KeySpec.input('=', label: '='),
    _KeySpec.input('(', label: '('),
    _KeySpec.input(')', label: ')'),
    _KeySpec.input(',', label: ','),
  ];

  @override
  State<CalculatorKeypad> createState() => _CalculatorKeypadState();
}

class _CalculatorKeypadState extends State<CalculatorKeypad> {
  static const double _categorySpacing = 16;
  static const double _categoryButtonSize = 92;
  static const double _optionButtonSize = 52;

  final GlobalKey _flickStackKey = GlobalKey();
  _FlickOverlayState? _activeFlick;

  @override
  void didUpdateWidget(covariant CalculatorKeypad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode &&
        widget.mode != KeypadLayoutMode.flick) {
      _closeFlick();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == KeypadLayoutMode.flick) {
      return _buildFlickKeyboard();
    }
    return _buildScrollableKeyboard();
  }

  Widget _buildFlickKeyboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            key: _flickStackKey,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                        child: LayoutBuilder(
                          builder: (context, innerConstraints) {
                            final double maxInset =
                                (innerConstraints.maxWidth / 2) -
                                (_categoryButtonSize / 2) -
                                8;
                            final double edgeInset = max(
                              16.0,
                              min(56.0, maxInset.isFinite ? maxInset : 56.0),
                            );
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: edgeInset,
                                ),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: _categorySpacing,
                                  runSpacing: _categorySpacing,
                                  children: [
                                    for (
                                      var i = 0;
                                      i < CalculatorKeypad._categories.length;
                                      i++
                                    )
                                      _buildCategoryButton(i),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildCommonKeyPanel(),
                  ],
                ),
              ),
              if (_activeFlick != null) _buildFlickOverlay(constraints),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollableKeyboard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildCategoryButton(0),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildCategoryButton(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildCategoryButton(2),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildCategoryButton(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildCommonKeyPanel(),
      ],
    );
  }

  Widget _buildCommonKeyPanel() {
    final keys = CalculatorKeypad._commonKeys;
    if (keys.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 16, 6, 6), // 上部の間隔を増やす
      child: LayoutBuilder(
        builder: (context, constraints) {
          const int columns = 6;
          const int rows = 2;
          const double horizontalSpacing = 4;
          const double verticalSpacing = 8;
          final double cellWidth =
              (constraints.maxWidth - horizontalSpacing * (columns - 1)) /
              columns;
          final double cellHeight = _optionButtonSize * 0.8; // 基本キーを小さくする

          const row1 = <_CommonKeyPlacement>[
            _CommonKeyPlacement(index: 0, column: 0, row: 0, rowSpan: 2),
            _CommonKeyPlacement(index: 1, column: 1, row: 0),
            _CommonKeyPlacement(index: 2, column: 2, row: 0),
            _CommonKeyPlacement(index: 3, column: 3, row: 0),
            _CommonKeyPlacement(index: 4, column: 4, row: 0),
            _CommonKeyPlacement(index: 5, column: 5, row: 0),
          ];

          const row2 = <_CommonKeyPlacement>[
            _CommonKeyPlacement(index: 6, column: 1, row: 1),
            _CommonKeyPlacement(index: 7, column: 2, row: 1),
            _CommonKeyPlacement(index: 8, column: 3, row: 1),
            _CommonKeyPlacement(index: 9, column: 4, row: 1),
            _CommonKeyPlacement(index: 10, column: 5, row: 1),
          ];

          final placements = <_CommonKeyPlacement>[
            ...row1,
            ...row2,
          ].where((placement) => placement.index < keys.length).toList();

          final double totalHeight =
              cellHeight * rows + verticalSpacing * (rows - 1);

          return SizedBox(
            width: constraints.maxWidth,
            height: totalHeight,
            child: Stack(
              children: [
                for (final placement in placements)
                  Positioned(
                    left: placement.column * (cellWidth + horizontalSpacing),
                    top: placement.row * (cellHeight + verticalSpacing),
                    width: cellWidth,
                    height:
                        cellHeight * placement.rowSpan +
                        verticalSpacing * (placement.rowSpan - 1),
                    child: _buildSmallRectKey(keys[placement.index]), // 小さなキー用のメソッドを使用
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryButton(int index) {
    final category = CalculatorKeypad._categories[index];
    final bool isActive = _activeFlick?.categoryIndex == index;

    return Builder(
      builder: (buttonContext) {
        return SizedBox(
          width: _categoryButtonSize,
          height: _categoryButtonSize,
          child: Material(
            color: isActive ? AppColors.primary : AppColors.primaryContainer,
            elevation: isActive ? 6 : 2,
            borderRadius: BorderRadius.circular(18),
            shadowColor: Colors.black.withValues(alpha: 0.08),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _toggleFlickMenu(index, buttonContext),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: 28,
                      color: isActive
                          ? AppColors.textOnPrimary
                          : AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? AppColors.textOnPrimary
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRectKey(_KeySpec spec) {
    return Material(
      color: AppColors.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _triggerKey(spec),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Text(
            spec.displayLabel,
            style: TextStyle(
              fontSize: spec.fontSize ?? 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallRectKey(_KeySpec spec) {
    return Material(
      color: AppColors.primaryContainer,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _triggerKey(spec),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Text(
            spec.displayLabel,
            style: TextStyle(
              fontSize: (spec.fontSize ?? 16) * 0.9, // フォントサイズも少し小さく
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildFlickOverlay(BoxConstraints constraints) {
    final overlay = _activeFlick!;
    final category = CalculatorKeypad._categories[overlay.categoryIndex];
    final keys = category.keys;
    final double baseRadius = _idealRadiusFor(keys.length);
    final double radius = _constrainRadius(
      baseRadius,
      overlay.center,
      keys.length,
      constraints,
    );

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _closeFlick,
        onPanUpdate: _handlePanUpdate,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: SizedBox.expand(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.0),
                        ],
                        radius: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: overlay.center.dx - (_optionButtonSize / 2),
              top: overlay.center.dy - (_optionButtonSize / 2),
              child: IgnorePointer(child: _buildCenterMarker(category)),
            ),
            for (var i = 0; i < keys.length; i++)
              _buildFlickOption(
                spec: keys[i],
                center: overlay.center,
                radius: radius,
                index: i,
                total: keys.length,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterMarker(_KeyCategory category) {
    return SizedBox(
      width: _optionButtonSize,
      height: _optionButtonSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            category.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlickOption({
    required _KeySpec spec,
    required Offset center,
    required double radius,
    required int index,
    required int total,
  }) {
    final double angle = (2 * pi / total) * index - (pi / 2);
    final double dx = center.dx + radius * cos(angle) - (_optionButtonSize / 2);
    final double dy = center.dy + radius * sin(angle) - (_optionButtonSize / 2);

    return Positioned(
      left: dx,
      top: dy,
      child: SizedBox(
        width: _optionButtonSize,
        height: _optionButtonSize,
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.14),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _handleFlickSelection(spec),
            splashColor: AppColors.primary.withValues(alpha: 0.12),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                spec.displayLabel,
                style: TextStyle(
                  fontSize: min(spec.fontSize ?? 16, 16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFlickMenu(int index, BuildContext buttonContext) {
    if (_activeFlick?.categoryIndex == index) {
      _closeFlick();
    } else {
      _openFlick(index, buttonContext);
    }
  }

  void _openFlick(int index, BuildContext buttonContext) {
    final RenderBox? stackBox =
        _flickStackKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? buttonBox = buttonContext.findRenderObject() as RenderBox?;
    if (stackBox == null || buttonBox == null) {
      return;
    }

    final Offset center = buttonBox.localToGlobal(
      buttonBox.size.center(Offset.zero),
      ancestor: stackBox,
    );

    setState(() {
      _activeFlick = _FlickOverlayState(categoryIndex: index, center: center);
    });
  }

  void _closeFlick() {
    if (_activeFlick == null) {
      return;
    }
    setState(() {
      _activeFlick = null;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_activeFlick == null) return;

    // Detect vertical drag (threshold: 5 pixels)
    if (details.delta.dy.abs() > 5) {
      final newCenter = Offset(
        _activeFlick!.center.dx,
        _activeFlick!.center.dy + details.delta.dy,
      );

      setState(() {
        _activeFlick = _FlickOverlayState(
          categoryIndex: _activeFlick!.categoryIndex,
          center: newCenter,
        );
      });
    }
  }

  void _handleFlickSelection(_KeySpec spec) {
    _triggerKey(spec);
    _closeFlick();
  }

  void _triggerKey(_KeySpec spec) {
    widget.onKeyPressed(CalculatorKeyEvent(spec.type, spec.value));
  }

  double _idealRadiusFor(int count) {
    const double minGapFromCenter = 12;
    if (count <= 1) {
      return _optionButtonSize + minGapFromCenter;
    }

    double optionSpacing;
    if (count >= 11) {
      optionSpacing = 28.0; // Numeric-rich categories
    } else if (count >= 9) {
      optionSpacing = 24.0; // Extended categories
    } else {
      optionSpacing = 16.0; // Compact categories
    }

    final double minChord = _optionButtonSize + optionSpacing;
    final double sinValue = sin(pi / count).clamp(0.08, 1.0);
    final double radius = minChord / (2 * sinValue);

    return max(_optionButtonSize + minGapFromCenter, radius);
  }

  double _constrainRadius(
    double baseRadius,
    Offset center,
    int total,
    BoxConstraints constraints,
  ) {
    const double margin = 0;
    const double epsilon = 1e-3;
    final double halfButton = _optionButtonSize / 2;
    double radius = baseRadius;

    for (var i = 0; i < total; i++) {
      final double angle = (2 * pi / total) * i - (pi / 2);
      final double cosValue = cos(angle);
      final double sinValue = sin(angle);

      double horizontalLimit = double.infinity;
      double verticalLimit = double.infinity;

      if (cosValue.abs() > epsilon) {
        if (cosValue > 0) {
          final double spaceRight =
              constraints.maxWidth - margin - halfButton - center.dx;
          horizontalLimit = spaceRight / cosValue;
        } else {
          final double spaceLeft = center.dx - margin - halfButton;
          horizontalLimit = spaceLeft / -cosValue;
        }
      }

      if (sinValue.abs() > epsilon) {
        if (sinValue > 0) {
          final double spaceDown =
              constraints.maxHeight - margin - halfButton - center.dy;
          verticalLimit = spaceDown / sinValue;
        } else {
          final double spaceUp = center.dy - margin - halfButton;
          verticalLimit = spaceUp / -sinValue;
        }
      }

      final double limit = min(horizontalLimit, verticalLimit);
      // Relax constraints so options stay visible near edges.
      if (limit.isFinite) {
        if (sinValue > 0) {
          // downward direction
          if (limit > baseRadius * 0.3) {
            radius = min(radius, limit);
          }
        } else {
          // upward or horizontal directions
          if (limit > baseRadius * 0.5) {
            radius = min(radius, limit);
          }
        }
      }
    }

    const double innerGap = 12;
    final double minRadius = _optionButtonSize + innerGap;
    radius = max(radius, minRadius);
    return radius;
  }
}

class _CommonKeyPlacement {
  const _CommonKeyPlacement({
    required this.index,
    required this.column,
    required this.row,
    this.rowSpan = 1,
  });

  final int index;
  final int column;
  final int row;
  final int rowSpan;
}

class _FlickOverlayState {
  const _FlickOverlayState({required this.categoryIndex, required this.center});

  final int categoryIndex;
  final Offset center;
}

class _KeyCategory {
  const _KeyCategory({
    required this.label,
    required this.keys,
    required this.icon,
  });

  final String label;
  final List<_KeySpec> keys;
  final IconData icon;
}

class _KeySpec {
  const _KeySpec(this.type, this.value, {this.label, this.fontSize});

  const _KeySpec.input(String value, {String? label, double? fontSize})
    : this(CalculatorKeyType.input, value, label: label, fontSize: fontSize);

  const _KeySpec.delete() : this(CalculatorKeyType.delete, 'DEL');

  const _KeySpec.moveLeft() : this(CalculatorKeyType.moveLeft, '\u2190');

  const _KeySpec.moveRight() : this(CalculatorKeyType.moveRight, '\u2192');

  final CalculatorKeyType type;
  final String value;
  final String? label;
  final double? fontSize;

  String get displayLabel => label ?? value;
}
