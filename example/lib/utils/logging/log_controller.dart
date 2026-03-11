import 'package:flutter/foundation.dart';

/// Controller for the virtualized log view.
/// Replaces TextEditingController for console/diagnostic output.
/// Lines are kept indefinitely – the VirtualizedLogView renders only
/// what is visible, so memory is the only practical limit.
class LogController extends ChangeNotifier {
  final List<String> _lines = [];

  LogController();

  // ── Public API ────────────────────────────────────────────────────────────

  /// All lines currently stored (read-only view).
  List<String> get lines => List.unmodifiable(_lines);

  /// Total number of lines.
  int get lineCount => _lines.length;

  /// Append a raw chunk of text (may contain newlines).
  /// Each '\n'-separated segment becomes its own line.
  void append(String text) {
    if (text.isEmpty) return;

    final incoming = text.split('\n');

    // If the last stored line doesn't end with '\n' yet, merge the first
    // incoming segment into it (mirrors how a terminal accumulates output).
    if (_lines.isNotEmpty && !_lines.last.endsWith('\n')) {
      _lines[_lines.length - 1] = _lines.last + incoming.first;
      for (int i = 1; i < incoming.length; i++) {
        _lines.add(incoming[i]);
      }
    } else {
      _lines.addAll(incoming);
    }

    notifyListeners();
  }

  /// Append a single pre-formatted line (no newline splitting).
  void appendLine(String line) {
    _lines.add(line);
    notifyListeners();
  }

  /// Replace all content with [text] (splits on newlines).
  set text(String text) {
    _lines
      ..clear()
      ..addAll(text.split('\n'));
    notifyListeners();
  }

  /// Returns all lines joined by '\n' (mirrors TextEditingController.text).
  String get text => _lines.join('\n');

  /// Remove every line.
  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
