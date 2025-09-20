import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/syntax_converter.dart';

@immutable
class ExpressionState {
  const ExpressionState({
    this.input = '',
    this.latex = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final String input;
  final String latex;
  final bool isLoading;
  final String? errorMessage;

  ExpressionState copyWith({
    String? input,
    String? latex,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return ExpressionState(
      input: input ?? this.input,
      latex: latex ?? this.latex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _sentinel = Object();
}

class ExpressionNotifier extends StateNotifier<ExpressionState> {
  ExpressionNotifier() : super(const ExpressionState());

  void updateInput(String value) {
    state = state.copyWith(
      input: value,
      latex: SyntaxConverter.calculatorToLatex(value.trimRight()),
    );
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  void reset() {
    state = const ExpressionState();
  }
}

final expressionProvider =
    StateNotifierProvider<ExpressionNotifier, ExpressionState>(
      (ref) {
        try {
          return ExpressionNotifier();
        } catch (e) {
          debugPrint('Error creating ExpressionNotifier: $e');
          return ExpressionNotifier();
        }
      },
    );
