enum KeypadLayoutMode { flick, scroll }

extension KeypadLayoutModeX on KeypadLayoutMode {
  static KeypadLayoutMode? fromName(String? value) {
    if (value == null) {
      return null;
    }
    return KeypadLayoutMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => KeypadLayoutMode.scroll,
    );
  }

  String get displayLabel {
    switch (this) {
      case KeypadLayoutMode.flick:
        return 'Radial';
      case KeypadLayoutMode.scroll:
        return 'Grid';
    }
  }
}
