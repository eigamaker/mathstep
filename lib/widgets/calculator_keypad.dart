import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_colors.dart';
import '../models/keypad_layout_mode.dart';
import '../localization/localization_extensions.dart';

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
      type: _KeyCategoryType.numbers,
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
      type: _KeyCategoryType.functions,
      icon: Icons.functions_rounded,
      keys: [
        _KeySpec.input('pow(', label: 'x^()'),
        _KeySpec.input('sqrt(', label: '\u221A'),
        _KeySpec.input('cbrt(', label: '\u221B'),
        _KeySpec.input('root(', label: '\u207F\u221A'),
        _KeySpec.input('frac(', label: 'a/b'),
        _KeySpec.input('abs(', label: '|x|'),
        _KeySpec.input('f(', label: 'f(x)'),
        _KeySpec.input('sin(', label: 'sin'),
        _KeySpec.input('cos(', label: 'cos'),
        _KeySpec.input('tan(', label: 'tan'),
        _KeySpec.input('ln(', label: 'ln'),
        _KeySpec.input('log(', label: 'log'),
        _KeySpec.input('n!', label: 'n!'),
      ],
    ),
    _KeyCategory(
      type: _KeyCategoryType.advanced,
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
      type: _KeyCategoryType.variables,
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
  static const double _horizontalPadding = 12;
  static const double _gridSpacing = 8;
  static const double _minTileExtent = 32;
  static const double _inkSplashAlpha = 0.08;
  static const double _inkHighlightAlpha = 0.05;
  static const double _inkBorderAlpha = 0.12;
  static const double _commonKeyHorizontalSpacing = 4;
  // Phone layout: delete key spans two rows.
  static const List<_CommonKeyPlacement> _commonKeyPlacements = [
    _CommonKeyPlacement(index: 0, column: 0, row: 0, rowSpan: 2),
    _CommonKeyPlacement(index: 1, column: 1, row: 0),
    _CommonKeyPlacement(index: 2, column: 2, row: 0),
    _CommonKeyPlacement(index: 3, column: 3, row: 0),
    _CommonKeyPlacement(index: 4, column: 4, row: 0),
    _CommonKeyPlacement(index: 5, column: 5, row: 0),
    _CommonKeyPlacement(index: 6, column: 1, row: 1),
    _CommonKeyPlacement(index: 7, column: 2, row: 1),
    _CommonKeyPlacement(index: 8, column: 3, row: 1),
    _CommonKeyPlacement(index: 9, column: 4, row: 1),
    _CommonKeyPlacement(index: 10, column: 5, row: 1),
  ];

  // Tablet layout: wider grid with two rows.
  static const List<_CommonKeyPlacement> _commonKeyPlacementsIPad = [
    _CommonKeyPlacement(index: 0, column: 0, row: 0, rowSpan: 2),
    _CommonKeyPlacement(index: 1, column: 1, row: 0),
    _CommonKeyPlacement(index: 2, column: 2, row: 0),
    _CommonKeyPlacement(index: 3, column: 3, row: 0),
    _CommonKeyPlacement(index: 4, column: 4, row: 0),
    _CommonKeyPlacement(index: 5, column: 5, row: 0),
    _CommonKeyPlacement(index: 6, column: 6, row: 0),
    _CommonKeyPlacement(index: 7, column: 7, row: 0),
    _CommonKeyPlacement(index: 8, column: 8, row: 0),
    _CommonKeyPlacement(index: 9, column: 9, row: 0),
    _CommonKeyPlacement(index: 10, column: 10, row: 0),
    _CommonKeyPlacement(index: 11, column: 11, row: 0),
    _CommonKeyPlacement(index: 12, column: 1, row: 1),
    _CommonKeyPlacement(index: 13, column: 2, row: 1),
    _CommonKeyPlacement(index: 14, column: 3, row: 1),
    _CommonKeyPlacement(index: 15, column: 4, row: 1),
    _CommonKeyPlacement(index: 16, column: 5, row: 1),
    _CommonKeyPlacement(index: 17, column: 6, row: 1),
    _CommonKeyPlacement(index: 18, column: 7, row: 1),
    _CommonKeyPlacement(index: 19, column: 8, row: 1),
    _CommonKeyPlacement(index: 20, column: 9, row: 1),
    _CommonKeyPlacement(index: 21, column: 10, row: 1),
    _CommonKeyPlacement(index: 22, column: 11, row: 1),
  ];

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
        // Adapt flick layout when vertical space is limited.
        final heightClass = _heightClassFor(constraints);
        final double categoryButtonSize = _categoryButtonSizeFor(heightClass);

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
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final double maxInset =
                                      (innerConstraints.maxWidth / 2) -
                                      (categoryButtonSize / 2) -
                                      8;
                                  final double edgeInset = max(
                                    16.0,
                                    min(
                                      56.0,
                                      maxInset.isFinite ? maxInset : 56.0,
                                    ),
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
                                            i <
                                                CalculatorKeypad
                                                    ._categories
                                                    .length;
                                            i++
                                          )
                                            _buildCategoryButton(
                                              i,
                                              categoryButtonSize,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildCommonKeyPanel(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_activeFlick != null)
                _buildFlickOverlay(context, constraints),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollableKeyboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine grid width based on platform.
        final bool isTablet = _isIPad(context);
        final int columns = _columnCount(isTablet);

        final double availableWidth = max(
          constraints.maxWidth - _horizontalPadding * 2,
          columns * _minTileExtent,
        );
        final double tileWidth =
            (availableWidth - _gridSpacing * (columns - 1)) / columns;
        // Compress tile height to keep the grid balanced on tablets.
        final double tileHeight = _scrollableTileHeight(isTablet, tileWidth);

        // Flatten categories into a single list for the scrollable view.
        final List<_KeySpec> allKeys = [
          ...CalculatorKeypad._commonKeys,
          for (final category in CalculatorKeypad._categories) ...category.keys,
        ];

        final int rowCount = (allKeys.length / columns).ceil();

        return ListView.builder(
          padding: EdgeInsets.all(_horizontalPadding),
          itemCount: rowCount,
          itemBuilder: (context, rowIndex) {
            final int startIndex = rowIndex * columns;
            final int endIndex = min(startIndex + columns, allKeys.length);
            final List<_KeySpec> rowKeys = allKeys.sublist(
              startIndex,
              endIndex,
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex < rowCount - 1 ? _gridSpacing : 0,
              ),
              child: Row(
                children: [
                  for (int i = 0; i < columns; i++)
                    Expanded(
                      child: i < rowKeys.length
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: _gridSpacing / 2,
                              ),
                              child: SizedBox(
                                height: tileHeight,
                                child: _buildScrollableKey(rowKeys[i]),
                              ),
                            )
                          : const SizedBox(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScrollableKey(_KeySpec spec) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust typography for phone and tablet layouts.
        final bool isTablet = _isIPad(context);
        final double fontSize = _scrollableFontSize(spec, isTablet);
        const double horizontalPadding = 4.0;
        final double verticalPadding = isTablet ? 6.0 : 8.0;
        final BorderRadius borderRadius = BorderRadius.circular(12);

        return Material(
          color: AppColors.primarySurface,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _triggerKey(spec),
            splashColor: AppColors.primary.withValues(alpha: _inkSplashAlpha),
            highlightColor: AppColors.primary.withValues(
              alpha: _inkHighlightAlpha,
            ),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: _inkBorderAlpha),
                  width: 1.1,
                ),
              ),
              child: Text(
                spec.displayLabel,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommonKeyPanel() {
    final keys = CalculatorKeypad._commonKeys;
    if (keys.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = _isIPad(context);
        final _HeightClass heightClass = _heightClassFor(constraints);
        final double baseButtonSize = _commonKeyBaseSize(
          isTablet: isTablet,
          heightClass: heightClass,
        );
        final int columns = _columnCount(isTablet);
        final double verticalSpacing = _commonKeyVerticalSpacing(heightClass);
        final double cellWidth =
            (constraints.maxWidth -
                _commonKeyHorizontalSpacing * (columns - 1)) /
            columns;
        final double cellHeight = baseButtonSize;
        final List<_CommonKeyPlacement> placements = _effectiveCommonPlacements(
          isTablet,
          keys.length,
        ).toList();
        final int rows = placements.isEmpty ? 0 : _rowCount(placements);
        final double totalHeight = rows <= 0
            ? cellHeight
            : cellHeight * rows + verticalSpacing * (rows - 1);
        final double topPadding = heightClass == _HeightClass.verySmall
            ? 8
            : 16;

        return Container(
          // Add breathing room above the quick keys.
          padding: EdgeInsets.fromLTRB(6, topPadding, 6, 6),
          child: SizedBox(
            width: constraints.maxWidth,
            height: totalHeight,
            child: Stack(
              children: [
                for (final placement in placements)
                  Positioned(
                    left:
                        placement.column *
                        (cellWidth + _commonKeyHorizontalSpacing),
                    top: placement.row * (cellHeight + verticalSpacing),
                    width: cellWidth,
                    height:
                        cellHeight * placement.rowSpan +
                        verticalSpacing * (placement.rowSpan - 1),
                    child: _buildCommonKey(
                      keys[placement.index],
                      baseButtonSize,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryButton(int index, [double? buttonSize]) {
    final category = CalculatorKeypad._categories[index];
    final bool isActive = _activeFlick?.categoryIndex == index;
    final double size = buttonSize ?? _categoryButtonSize;

    final BorderRadius borderRadius = BorderRadius.circular(size * 0.2);
    final EdgeInsets contentPadding = EdgeInsets.all(size * 0.13);
    final double iconSize = size * 0.3;
    final double labelGap = size * 0.09;
    final double labelFontSize = size * 0.15;

    return Builder(
      builder: (buttonContext) {
        return SizedBox(
          width: size,
          height: size,
          child: Material(
            color: isActive ? AppColors.primary : AppColors.primaryContainer,
            elevation: isActive ? 6 : 2,
            borderRadius: borderRadius,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            child: InkWell(
              borderRadius: borderRadius,
              onTap: () => _toggleFlickMenu(index, buttonContext),
              child: Padding(
                padding: contentPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: iconSize,
                      color: isActive
                          ? AppColors.textOnPrimary
                          : AppColors.primary,
                    ),
                    SizedBox(height: labelGap),
                    Text(
                      category.label(buttonContext),
                      style: TextStyle(
                        fontSize: labelFontSize,
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

  Widget _buildCommonKey(_KeySpec spec, [double? buttonSize]) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = _isIPad(context);
        final double size = buttonSize ?? _optionButtonSize * 0.8;
        final BorderRadius borderRadius = BorderRadius.circular(size * 0.2);
        final double fontSize = _commonKeyFontSize(spec, size, isTablet);
        final EdgeInsets padding = EdgeInsets.symmetric(
          horizontal: size * 0.12,
          vertical: size * 0.15,
        );

        return Material(
          color: AppColors.primaryContainer,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _triggerKey(spec),
            splashColor: AppColors.primary.withValues(alpha: _inkSplashAlpha),
            highlightColor: AppColors.primary.withValues(
              alpha: _inkHighlightAlpha,
            ),
            child: Container(
              alignment: Alignment.center,
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: _inkBorderAlpha),
                  width: 1,
                ),
              ),
              child: Text(
                spec.displayLabel,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlickOverlay(BuildContext context, BoxConstraints constraints) {
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
              child: IgnorePointer(
                child: _buildCenterMarker(context, category),
              ),
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

  Widget _buildCenterMarker(BuildContext context, _KeyCategory category) {
    final label = category.label(context);
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
            label,
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

  _HeightClass _heightClassFor(BoxConstraints constraints) {
    final height = constraints.maxHeight;
    if (!height.isFinite) {
      return _HeightClass.regular;
    }
    if (height < 500) {
      return _HeightClass.verySmall;
    }
    if (height < 600) {
      return _HeightClass.small;
    }
    return _HeightClass.regular;
  }

  double _categoryButtonSizeFor(_HeightClass heightClass) {
    switch (heightClass) {
      case _HeightClass.verySmall:
        return _categoryButtonSize * 0.8;
      case _HeightClass.small:
        return _categoryButtonSize * 0.9;
      case _HeightClass.regular:
        return _categoryButtonSize;
    }
  }

  double _commonKeyBaseSize({
    required bool isTablet,
    required _HeightClass heightClass,
  }) {
    switch (heightClass) {
      case _HeightClass.verySmall:
        return _optionButtonSize * 0.6;
      case _HeightClass.small:
        return _optionButtonSize * 0.7;
      case _HeightClass.regular:
        return isTablet ? _optionButtonSize * 0.6 : _optionButtonSize * 0.8;
    }
  }

  double _commonKeyVerticalSpacing(_HeightClass heightClass) {
    return heightClass == _HeightClass.verySmall ? 4 : 8;
  }

  Iterable<_CommonKeyPlacement> _effectiveCommonPlacements(
    bool isTablet,
    int keyCount,
  ) {
    final source = isTablet ? _commonKeyPlacementsIPad : _commonKeyPlacements;
    return source.where((placement) => placement.index < keyCount);
  }

  int _rowCount(Iterable<_CommonKeyPlacement> placements) {
    var maxRow = 0;
    for (final placement in placements) {
      final rowEnd = placement.row + placement.rowSpan;
      if (rowEnd > maxRow) {
        maxRow = rowEnd;
      }
    }
    return maxRow;
  }

  int _columnCount(bool isTablet) => isTablet ? 12 : 6;

  double _scrollableTileHeight(bool isTablet, double tileWidth) {
    if (isTablet) {
      return max(_optionButtonSize * 0.5, tileWidth * 0.7);
    }
    return max(_optionButtonSize, tileWidth * 1.1);
  }

  double _scrollableFontSize(_KeySpec spec, bool isTablet) {
    final base = spec.fontSize ?? 14;
    if (isTablet) {
      return min(base * 2.2, 28);
    }
    return min(base, 16);
  }

  double _commonKeyFontSize(_KeySpec spec, double size, bool isTablet) {
    final baseFontSize = spec.fontSize ?? 16;
    if (isTablet) {
      return baseFontSize * 2.0;
    }
    return baseFontSize * (size / _optionButtonSize);
  }

  /// Determine whether the current device should use the tablet layout.
  bool _isIPad(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return false;
    }

    final Size size = mediaQuery.size;
    final double shortestSide = min(size.width, size.height);
    final bool isCupertinoPlatform =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    return isCupertinoPlatform && shortestSide >= 600;
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

enum _HeightClass { regular, small, verySmall }

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

enum _KeyCategoryType { numbers, functions, advanced, variables }

class _KeyCategory {
  const _KeyCategory({
    required this.type,
    required this.keys,
    required this.icon,
  });

  final _KeyCategoryType type;
  final List<_KeySpec> keys;
  final IconData icon;

  String label(BuildContext context) {
    final l10n = context.l10n;
    switch (type) {
      case _KeyCategoryType.numbers:
        return l10n.keypadCategoryNumbers;
      case _KeyCategoryType.functions:
        return l10n.keypadCategoryFunctions;
      case _KeyCategoryType.advanced:
        return l10n.keypadCategoryAdvanced;
      case _KeyCategoryType.variables:
        return l10n.keypadCategoryVariables;
    }
  }
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
