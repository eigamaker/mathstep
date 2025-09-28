from pathlib import Path

path = Path("lib/services/json_parser.dart")
text = path.read_text()
start = text.index("    return normalised.replaceAllMapped(")
end = text.index("  /// Decodes a JSON string", start)
replacement = "    return normalised.replaceAllMapped(\n      RegExp(r'\\\\(?![\"\\\\/bfnrtu])'),\n      (_) => r'\\\\',\n    );\n\n"
# Wait this still escapes for dart? need to compute carefully
