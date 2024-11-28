import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoadmapVisualization extends StatefulWidget {
  final List<String> unlockedDays;
  final Function(String day, int dayIndex) onNodeTap;
  final Map<String, String> dayTitles;
  final Color lockedColor;
  final Color unlockedColor;

  const RoadmapVisualization({
    super.key,
    required this.unlockedDays,
    required this.onNodeTap,
    required this.dayTitles,
    this.lockedColor = Colors.grey,
    this.unlockedColor = Colors.green,
  });

  @override
  State<RoadmapVisualization> createState() => _RoadmapVisualizationState();
}

class _RoadmapVisualizationState extends State<RoadmapVisualization>
    with SingleTickerProviderStateMixin {
  List<Offset> nodePositions = [];
  late AnimationController _pathAnimationController;
  final double verticalSpacing = 120.0;
  final double horizontalPadding = 40.0;
  bool isLoading = true;
  bool _isRandomizationAttempted = false;

  @override
  void initState() {
    super.initState();
    _pathAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _initializeNodePositions();
  }

  Future<void> _initializeNodePositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPositions = prefs.getStringList('nodePositions');

      if (savedPositions != null && savedPositions.length == 6) {
        // Load saved positions
        nodePositions = savedPositions.map((pos) {
          final coords = pos.split(',');
          return Offset(double.parse(coords[0]), double.parse(coords[1]));
        }).toList();
      } else {
        // Trigger positions generation after layout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _generateRandomPositions();
        });
      }
    } catch (e) {
      // Fallback to random generation if loading fails
      _generateRandomPositions();
    } finally {
      setState(() => isLoading = false);
      _pathAnimationController.forward();
    }
  }

  void _generateRandomPositions() {
    if (_isRandomizationAttempted) return;
    _isRandomizationAttempted = true;

    final random = Random();
    nodePositions = List.generate(6, (index) {
      final screenWidth = MediaQuery.of(context).size.width;
      final availableWidth = screenWidth - (2 * horizontalPadding);

      // Introduce more controlled randomness
      final xVariation =
          random.nextDouble() * 0.4 + 0.3; // 30-70% of available width
      final x = horizontalPadding + (availableWidth * xVariation);
      final y = 100.0 + (index * verticalSpacing);

      return Offset(x, y);
    });

    _saveNodePositions();
  }

  void _saveNodePositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionsAsString =
          nodePositions.map((offset) => '${offset.dx},${offset.dy}').toList();
      await prefs.setStringList('nodePositions', positionsAsString);
    } catch (e) {
      debugPrint('Error saving node positions: $e');
    }
  }

  Widget _buildNodeWidget(int index) {
    final day = 'day${index + 1}';
    final isUnlocked = widget.unlockedDays.contains(day);
    final title = widget.dayTitles[day] ?? 'Day ${index + 1}';

    return Positioned(
      left: nodePositions[index].dx - 24,
      top: nodePositions[index].dy - 24,
      child: GestureDetector(
        onTap: isUnlocked ? () => widget.onNodeTap(day, index + 1) : null,
        child: Container(
          width: 200, // Increased width for better layout
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked ? widget.unlockedColor : widget.lockedColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isUnlocked ? Icons.check : Icons.lock,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: isUnlocked ? Colors.white : Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    return SingleChildScrollView(
      child: SizedBox(
        height: nodePositions.last.dy + 200, // Added extra padding
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: RoadmapPathPainter(
                nodePositions: nodePositions,
                unlockedDays: widget.unlockedDays,
                lockedColor: widget.lockedColor,
                unlockedColor: widget.unlockedColor,
                animation: _pathAnimationController,
              ),
            ),
            ...List.generate(6, _buildNodeWidget),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pathAnimationController.dispose();
    super.dispose();
  }
}

class RoadmapPathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final List<String> unlockedDays;
  final Animation<double> animation;
  final Color lockedColor;
  final Color unlockedColor;

  RoadmapPathPainter({
    required this.nodePositions,
    required this.unlockedDays,
    required this.animation,
    required this.lockedColor,
    required this.unlockedColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final lockedPaint = Paint()
      ..color = lockedColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final unlockedPaint = Paint()
      ..color = unlockedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Create and draw the full path
    final fullPath = _createCubicPath(nodePositions);
    canvas.drawPath(fullPath, lockedPaint);

    // Draw the unlocked portion with animation
    if (unlockedDays.isNotEmpty) {
      final lastUnlockedDayNum = unlockedDays.map((day) {
        return int.parse(day.replaceAll('day', ''));
      }).reduce(max);

      final unlockedPath = _createPartialPath(lastUnlockedDayNum);

      if (unlockedPath != null) {
        final pathMetrics = unlockedPath.computeMetrics().first;
        final extractPath = Path();
        extractPath.addPath(
          pathMetrics.extractPath(
            0,
            pathMetrics.length *
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ).value,
          ),
          Offset.zero,
        );
        canvas.drawPath(extractPath, unlockedPaint);
      }
    }
  }

  Path _createCubicPath(List<Offset> positions) {
    final path = Path();
    for (int i = 0; i < positions.length - 1; i++) {
      final start = positions[i];
      final end = positions[i + 1];
      final controlPoint1 = Offset(start.dx, (start.dy + end.dy) / 2);
      final controlPoint2 = Offset(end.dx, (start.dy + end.dy) / 2);

      if (i == 0) path.moveTo(start.dx, start.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );
    }
    return path;
  }

  Path? _createPartialPath(int lastUnlockedDayNum) {
    if (lastUnlockedDayNum <= 1) return null;

    final unlockedPositions = nodePositions.sublist(0, lastUnlockedDayNum);
    return _createCubicPath(unlockedPositions);
  }

  @override
  bool shouldRepaint(RoadmapPathPainter oldDelegate) {
    return oldDelegate.unlockedDays != unlockedDays ||
        oldDelegate.animation.value != animation.value;
  }
}
