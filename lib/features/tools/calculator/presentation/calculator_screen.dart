import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:math_expressions/math_expressions.dart' hide Stack;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/haptics_engine.dart';

class CalcHistoryItem {
  final String equation;
  final String result;
  bool isPinned;

  CalcHistoryItem(this.equation, this.result, {this.isPinned = false});

  Map<String, dynamic> toJson() => {'eq': equation, 'res': result, 'pinned': isPinned};
  factory CalcHistoryItem.fromJson(Map<String, dynamic> json) => CalcHistoryItem(json['eq'] ?? '', json['res'] ?? '', isPinned: json['pinned'] ?? false);
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _equation = '';
  String _result = '0';
  String _livePreview = '';
  bool _isScientific = false;
  bool _justCalculated = false;
  List<CalcHistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      final List<String> raw = prefs.getStringList('calculator_history') ?? [];
      setState(() {
        _history = raw.map((e) {
          if (e.contains(' = ')) {
            final parts = e.split(' = ');
            return CalcHistoryItem(parts[0], parts[1]);
          } else {
            try {
              return CalcHistoryItem.fromJson(jsonDecode(e));
            } catch (_) {
              return CalcHistoryItem('', '');
            }
          }
        }).where((item) => item.equation.isNotEmpty).toList();
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('calculator_history', raw);
  }

  void buttonPressed(String buttonText) {
    HapticsEngine.selectionClick();

    setState(() {
      if (buttonText == 'AC') {
        _equation = '';
        _result = '0';
        _livePreview = '';
        _justCalculated = false;
      } else if (buttonText == '⌫') {
        if (_equation.isNotEmpty) {
          _equation = _equation.substring(0, _equation.length - 1);
          _justCalculated = false;
          _tryLiveEval();
        }
      } else if (buttonText == '=') {
        _calculate(finalize: true);
      } else if (buttonText == 'sin' || buttonText == 'cos' || buttonText == 'tan' || buttonText == 'log' || buttonText == 'ln') {
        if (_justCalculated) _equation = '';
        _equation += '$buttonText(';
        _justCalculated = false;
        _tryLiveEval();
      } else if (buttonText == '√') {
        if (_justCalculated) _equation = '';
        _equation += 'sqrt(';
        _justCalculated = false;
        _tryLiveEval();
      } else if (buttonText == '^') {
        if (_justCalculated) _equation = _result;
        _equation += '^';
        _justCalculated = false;
        _tryLiveEval();
      } else {
        if (_justCalculated) {
          if (_isDigitOrDot(buttonText)) {
            _equation = buttonText;
          } else {
            // Continuation of previous result
            _equation = _result.replaceAll(',', '') + buttonText;
          }
          _justCalculated = false;
        } else {
          _equation += buttonText;
        }
        _tryLiveEval();
      }
    });
  }

  bool _isDigitOrDot(String s) => RegExp(r'^[0-9.]$').hasMatch(s);

  void _tryLiveEval() {
    if (_equation.isEmpty) {
      _livePreview = '';
      return;
    }
    try {
      String expr = _prepareExpression(_equation);
      // Strip trailing operators for silent evaluation
      while (expr.isNotEmpty && "+-*/^".contains(expr[expr.length - 1])) {
        expr = expr.substring(0, expr.length - 1);
      }
      if (expr.isEmpty) {
        _livePreview = '';
        return;
      }
      Parser p = Parser();
      Expression e = p.parse(expr);
      ContextModel cm = ContextModel();
      double val = e.evaluate(EvaluationType.REAL, cm);
      if (val.isNaN || val.isInfinite) {
        // Keep previous valid preview if invalid
      } else {
        _livePreview = _formatResult(val);
      }
    } catch (_) {
      // Expression incomplete — silent
    }
  }

  String _prepareExpression(String raw) {
    return raw
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', math.pi.toString())
        .replaceAll('e', math.e.toString());
  }

  void _calculate({bool finalize = false}) {
    if (_equation.isEmpty) return;
    try {
      String expr = _prepareExpression(_equation);
      Parser p = Parser();
      Expression e = p.parse(expr);
      ContextModel cm = ContextModel();
      double val = e.evaluate(EvaluationType.REAL, cm);
      String res = _formatResult(val);
      _result = res;
      _livePreview = '';
      if (finalize) {
        final newItem = CalcHistoryItem(_equation, _result);
        final firstUnpinned = _history.indexWhere((item) => !item.isPinned);
        if (firstUnpinned == -1) {
          _history.add(newItem);
        } else {
          _history.insert(firstUnpinned, newItem);
        }
        if (_history.length > 50) _history.removeLast();
        _saveHistory();
        HapticsEngine.heavyImpact();
        _justCalculated = true;
      }
    } catch (e) {
      _result = 'Error';
      HapticsEngine.heavyImpact();
    }
  }

  String _formatResult(double val) {
    if (val % 1 == 0 && val.abs() < 1e15) {
      return _addCommas(val.toInt().toString());
    } else {
      String s = val.toStringAsFixed(8);
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      List<String> parts = s.split('.');
      parts[0] = _addCommas(parts[0]);
      return parts.join('.');
    }
  }

  String _addCommas(String num) {
    if (num.length <= 3) return num;
    final sign = num.startsWith('-') ? '-' : '';
    final digits = num.replaceAll('-', '');
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return sign + digits.replaceAllMapped(reg, (m) => '${m[1]},');
  }

  void _showHistorySheet() {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() { _history.clear(); });
                      _saveHistory();
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _history.isEmpty
                    ? Center(child: Text('No history yet', style: TextStyle(color: isDark ? Colors.white54 : Colors.black38)))
                    : StatefulBuilder(
                        builder: (BuildContext context, StateSetter setModalState) {
                          return ListView.builder(
                            itemCount: _history.length,
                            itemBuilder: (_, i) {
                              final item = _history[i];
                              return ListTile(
                                title: Text(item.equation, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 14)),
                                subtitle: Text(item.result, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).primaryColor)),
                                trailing: IconButton(
                                  icon: Icon(item.isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: item.isPinned ? Theme.of(context).primaryColor : Colors.grey),
                                  onPressed: () {
                                    HapticsEngine.selectionClick();
                                    setModalState(() {
                                      item.isPinned = !item.isPinned;
                                      // Re-sort history: pinned on top, unpinned below
                                      _history.sort((a, b) {
                                        if (a.isPinned && !b.isPinned) return -1;
                                        if (!a.isPinned && b.isPinned) return 1;
                                        return 0; // maintain relative order otherwise (this is a simplified sort that might mess up chronological order among pinned/unpinned if not careful, but since we insert unpinned at firstUnpinned index, it's ok)
                                      });
                                    });
                                    setState(() {});
                                    _saveHistory();
                                  },
                                ),
                                onLongPress: () {
                                  HapticsEngine.heavyImpact();
                                  setModalState(() {
                                    _history.removeAt(i);
                                  });
                                  setState(() {});
                                  _saveHistory();
                                },
                                onTap: () {
                                  setState(() {
                                    _equation = item.equation;
                                    _result = item.result;
                                    _justCalculated = true;
                                  });
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          );
                        }
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black45;
    final primary = Theme.of(context).primaryColor;

    final displayResult = _justCalculated ? _result : (_livePreview.isNotEmpty ? _livePreview : '');
    final isPreview = _livePreview.isNotEmpty && !_justCalculated;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
          },
        ),
        title: Text('Calculator', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.science_outlined, color: _isScientific ? primary : subColor),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _isScientific = !_isScientific);
            },
          ),
          IconButton(
            icon: Icon(Icons.history, color: subColor),
            onPressed: _showHistorySheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Display
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Clean Equation Display
                  Container(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _equation,
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: textColor),
                          ),
                          if (!_justCalculated && _equation.isNotEmpty)
                            Container(
                              width: 3,
                              height: 40,
                              margin: const EdgeInsets.only(left: 4, top: 4),
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(duration: 400.ms, curve: Curves.easeInOut),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Animated Result
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation), child: child)),
                    child: Text(
                      displayResult.isEmpty && _equation.isEmpty ? '0' : displayResult,
                      key: ValueKey(displayResult),
                      style: TextStyle(
                        fontSize: isPreview ? 32 : 56,
                        fontWeight: isPreview ? FontWeight.w400 : FontWeight.bold,
                        color: isPreview ? subColor : primary,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Keypad
          Expanded(
            flex: _isScientific ? 5 : 4,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, -6)),
                ],
              ),
              child: Column(
                children: [
                  if (_isScientific) ...[
                    Expanded(child: Row(
                      children: ['sin', 'cos', 'tan', '√', '^']
                          .map((t) => _btn(t, isScientific: true))
                          .toList(),
                    )),
                    const SizedBox(height: 10),
                    Expanded(child: Row(
                      children: ['log', 'ln', '(', ')', 'π']
                          .map((t) => _btn(t, isScientific: true))
                          .toList(),
                    )),
                    const SizedBox(height: 10),
                  ],
                  Expanded(child: Row(children: [
                    _btn('AC', isSpecial: true),
                    _btn('⌫', isSpecial: true, icon: Icons.backspace_outlined),
                    _btn('%', isOperator: true),
                    _btn('÷', isOperator: true),
                  ])),
                  const SizedBox(height: 10),
                  Expanded(child: Row(children: [_btn('7'), _btn('8'), _btn('9'), _btn('×', isOperator: true)])),
                  const SizedBox(height: 10),
                  Expanded(child: Row(children: [_btn('4'), _btn('5'), _btn('6'), _btn('-', isOperator: true)])),
                  const SizedBox(height: 10),
                  Expanded(child: Row(children: [_btn('1'), _btn('2'), _btn('3'), _btn('+', isOperator: true)])),
                  const SizedBox(height: 10),
                  Expanded(child: Row(children: [_btn('00'), _btn('0'), _btn('.'), _btn('=', isEquals: true)])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(String text, {bool isOperator = false, bool isSpecial = false, bool isEquals = false, bool isScientific = false, IconData? icon}) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: isScientific ? 1.2 : 1.0,
        child: Container(
          margin: const EdgeInsets.all(5),
          child: _CalcButton(
            text: text,
            icon: icon,
            isOperator: isOperator,
            isSpecial: isSpecial,
            isEquals: isEquals,
            isScientific: isScientific,
            onPressed: () => buttonPressed(text),
          ),
        ),
      ),
    );
  }
}

class _CalcButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final bool isOperator;
  final bool isSpecial;
  final bool isEquals;
  final bool isScientific;
  final VoidCallback onPressed;

  const _CalcButton({
    required this.text,
    this.icon,
    this.isOperator = false,
    this.isSpecial = false,
    this.isEquals = false,
    this.isScientific = false,
    required this.onPressed,
  });

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack, reverseCurve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    Color bgColor() {
      if (widget.isEquals) return primary;
      if (widget.isOperator) return isDark ? const Color(0xFF2A2040) : const Color(0xFFEDE9FF);
      if (widget.isSpecial) return isDark ? const Color(0xFF2A2040) : const Color(0xFFFFEEEE);
      return isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF7F8FA);
    }

    Color textColor() {
      if (widget.isEquals) return Colors.white;
      if (widget.isSpecial) return const Color(0xFFFF4B4B);
      if (widget.isOperator) return primary;
      return isDark ? Colors.white : Colors.black87;
    }

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.isScientific ? BorderRadius.circular(16) : BorderRadius.circular(100),
          boxShadow: widget.isEquals
              ? [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 5))]
              : [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Material(
          color: bgColor(),
          shape: widget.isScientific
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              : const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onHighlightChanged: (isHighlighted) {
              if (isHighlighted) {
                setState(() => _isPressed = true);
                _ctrl.forward();
              } else {
                setState(() => _isPressed = false);
                _ctrl.reverse();
              }
            },
            onTap: widget.onPressed,
            splashColor: const Color(0xFF8A2BE2).withOpacity(0.4),
            highlightColor: const Color(0xFF4B0082).withOpacity(0.2),
            child: Container(
              alignment: Alignment.center,
              child: widget.icon != null
                  ? Icon(widget.icon, color: textColor(), size: widget.isScientific ? 18 : 24)
                  : Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: widget.isScientific ? 15 : 26,
                        fontWeight: widget.isOperator || widget.isEquals || widget.isSpecial ? FontWeight.w700 : FontWeight.w500,
                        color: textColor(),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
