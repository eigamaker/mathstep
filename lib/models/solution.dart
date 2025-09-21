class Solution {
  final String id;
  final String mathExpressionId;
  final String? problemStatement;
  final List<SolutionStep> steps;
  final List<AlternativeSolution>? alternativeSolutions;
  final Verification? verification;
  final DateTime timestamp;

  const Solution({
    required this.id,
    required this.mathExpressionId,
    this.problemStatement,
    required this.steps,
    this.alternativeSolutions,
    this.verification,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mathExpressionId': mathExpressionId,
      'problemStatement': problemStatement,
      'steps': steps.map((step) => step.toJson()).toList(),
      'alternativeSolutions': alternativeSolutions
          ?.map((alt) => alt.toJson())
          .toList(),
      'verification': verification?.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Solution.fromJson(Map<String, dynamic> json) {
    return Solution(
      id: json['id'],
      mathExpressionId: json['mathExpressionId'],
      problemStatement: json['problemStatement'],
      steps: (json['steps'] as List)
          .map((step) => SolutionStep.fromJson(step))
          .toList(),
      alternativeSolutions: json['alternativeSolutions'] != null
          ? (json['alternativeSolutions'] as List)
                .map((alt) => AlternativeSolution.fromJson(alt))
                .toList()
          : null,
      verification: json['verification'] != null
          ? Verification.fromJson(json['verification'])
          : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Solution copyWith({
    String? id,
    String? mathExpressionId,
    String? problemStatement,
    List<SolutionStep>? steps,
    List<AlternativeSolution>? alternativeSolutions,
    Verification? verification,
    DateTime? timestamp,
  }) {
    return Solution(
      id: id ?? this.id,
      mathExpressionId: mathExpressionId ?? this.mathExpressionId,
      problemStatement: problemStatement ?? this.problemStatement,
      steps: steps ?? this.steps,
      alternativeSolutions: alternativeSolutions ?? this.alternativeSolutions,
      verification: verification ?? this.verification,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class SolutionStep {
  final String id;
  final String title;
  final String description;
  final String? latexExpression;
  final bool isExpanded;

  const SolutionStep({
    required this.id,
    required this.title,
    required this.description,
    this.latexExpression,
    this.isExpanded = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latexExpression': latexExpression,
      'isExpanded': isExpanded,
    };
  }

  factory SolutionStep.fromJson(Map<String, dynamic> json) {
    return SolutionStep(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      latexExpression: json['latexExpression'],
      isExpanded: json['isExpanded'] ?? false,
    );
  }

  SolutionStep copyWith({
    String? id,
    String? title,
    String? description,
    String? latexExpression,
    bool? isExpanded,
  }) {
    return SolutionStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latexExpression: latexExpression ?? this.latexExpression,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class AlternativeSolution {
  final String id;
  final String title;
  final List<SolutionStep> steps;

  const AlternativeSolution({
    required this.id,
    required this.title,
    required this.steps,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  factory AlternativeSolution.fromJson(Map<String, dynamic> json) {
    return AlternativeSolution(
      id: json['id'],
      title: json['title'],
      steps: (json['steps'] as List)
          .map((step) => SolutionStep.fromJson(step))
          .toList(),
    );
  }
}

class Verification {
  final String? domainCheck;
  final String? verification;
  final String? commonMistakes;

  const Verification({
    this.domainCheck,
    this.verification,
    this.commonMistakes,
  });

  Map<String, dynamic> toJson() {
    return {
      'domainCheck': domainCheck,
      'verification': verification,
      'commonMistakes': commonMistakes,
    };
  }

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      domainCheck: json['domainCheck'],
      verification: json['verification'],
      commonMistakes: json['commonMistakes'],
    );
  }
}
