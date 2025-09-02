class MathExpression {
  final String id;
  final String calculatorSyntax;
  final String latexExpression;
  final DateTime timestamp;
  final String? tag;
  final String? notes;

  MathExpression({
    required this.id,
    required this.calculatorSyntax,
    required this.latexExpression,
    required this.timestamp,
    this.tag,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calculatorSyntax': calculatorSyntax,
      'latexExpression': latexExpression,
      'timestamp': timestamp.toIso8601String(),
      'tag': tag,
      'notes': notes,
    };
  }

  factory MathExpression.fromJson(Map<String, dynamic> json) {
    return MathExpression(
      id: json['id'],
      calculatorSyntax: json['calculatorSyntax'],
      latexExpression: json['latexExpression'],
      timestamp: DateTime.parse(json['timestamp']),
      tag: json['tag'],
      notes: json['notes'],
    );
  }

  MathExpression copyWith({
    String? id,
    String? calculatorSyntax,
    String? latexExpression,
    DateTime? timestamp,
    String? tag,
    String? notes,
  }) {
    return MathExpression(
      id: id ?? this.id,
      calculatorSyntax: calculatorSyntax ?? this.calculatorSyntax,
      latexExpression: latexExpression ?? this.latexExpression,
      timestamp: timestamp ?? this.timestamp,
      tag: tag ?? this.tag,
      notes: notes ?? this.notes,
    );
  }
}
