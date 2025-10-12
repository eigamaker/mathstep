class Solution {
  final String id;
  final String mathExpressionId;
  final String? problemStatement;
  final List<SolutionStep> steps;
  final List<SimilarProblem>? similarProblems;
  final DateTime timestamp;

  const Solution({
    required this.id,
    required this.mathExpressionId,
    this.problemStatement,
    required this.steps,
    this.similarProblems,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mathExpressionId': mathExpressionId,
      'problemStatement': problemStatement,
      'steps': steps.map((step) => step.toJson()).toList(),
      'similarProblems': similarProblems
          ?.map((similar) => similar.toJson())
          .toList(),
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
      similarProblems: json['similarProblems'] != null
          ? (json['similarProblems'] as List)
                .map((similar) => SimilarProblem.fromJson(similar))
                .toList()
          : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Solution copyWith({
    String? id,
    String? mathExpressionId,
    String? problemStatement,
    List<SolutionStep>? steps,
    List<SimilarProblem>? similarProblems,
    DateTime? timestamp,
  }) {
    return Solution(
      id: id ?? this.id,
      mathExpressionId: mathExpressionId ?? this.mathExpressionId,
      problemStatement: problemStatement ?? this.problemStatement,
      steps: steps ?? this.steps,
      similarProblems: similarProblems ?? this.similarProblems,
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

class SimilarProblem {
  final String id;
  final String title;
  final String description;
  final String problemExpression;
  final List<SolutionStep> solutionSteps;

  const SimilarProblem({
    required this.id,
    required this.title,
    required this.description,
    required this.problemExpression,
    required this.solutionSteps,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'problemExpression': problemExpression,
      'solutionSteps': solutionSteps.map((step) => step.toJson()).toList(),
    };
  }

  factory SimilarProblem.fromJson(Map<String, dynamic> json) {
    return SimilarProblem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      problemExpression: json['problemExpression'],
      solutionSteps: (json['solutionSteps'] as List)
          .map((step) => SolutionStep.fromJson(step))
          .toList(),
    );
  }
}
