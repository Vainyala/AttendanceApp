import 'package:AttendanceApp/manager/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import 'package:flutter/material.dart';

class GraphToggle extends StatefulWidget {
  final AttendanceAnalyticsViewModel viewModel;
  final Function(int)? onViewChanged;

  const GraphToggle({super.key, required this.viewModel, this.onViewChanged});

  @override
  State<GraphToggle> createState() => _GraphToggleState();
}

class _GraphToggleState extends State<GraphToggle> {
  int _currentView = 0; // 0 = Merged, 1 = Individual, 2 = Project
  int? _hoveredView;
  bool _showHoverIndicator = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.grey.shade800 : Colors.white,
          border: Border.all(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current View Icon
            _buildViewIcon(isDark),
            const SizedBox(width: 12),

            // Three-Way Toggle Switch
            _buildThreeWayToggle(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildViewIcon(bool isDark) {
    IconData icon;
    Color color;

    switch (_currentView) {
      case 0:
        icon = Icons.group;
        color = isDark ? Colors.cyan.shade300 : Colors.cyan.shade600;
        break;
      case 1:
        icon = Icons.person;
        color = isDark ? Colors.orange.shade300 : Colors.orange.shade600;
        break;
      case 2:
        icon = Icons.pie_chart_rounded;
        color = isDark ? Colors.purple.shade300 : Colors.purple.shade600;
        break;
      default:
        icon = Icons.group;
        color = isDark ? Colors.cyan : Colors.cyan.shade700;
    }

    return Icon(icon, size: 18, color: color);
  }

  Widget _buildThreeWayToggle(bool isDark) {
    return Container(
      width: 80,
      height: 32,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
      child: Stack(
        children: [
          // Background Selection
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _currentView * 26.0, // 26px per option
            child: Container(
              width: 26,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: _getBorderRadiusForPosition(_currentView),
                gradient: _getGradientForView(_currentView, isDark),
                boxShadow: [
                  BoxShadow(
                    color: _getColorForView(
                      _currentView,
                      isDark,
                    ).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Hover Indicator
          if (_showHoverIndicator && _hoveredView != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: _hoveredView! * 26.0,
              child: Container(
                width: 26,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: _getBorderRadiusForPosition(_hoveredView!),
                  border: Border.all(
                    color: _getColorForView(
                      _hoveredView!,
                      isDark,
                    ).withOpacity(0.6),
                    width: 2,
                  ),
                ),
              ),
            ),

          // Toggle Options
          Row(
            children: [
              _buildToggleOption(0, Icons.group, isDark),
              _buildToggleOption(1, Icons.person, isDark),
              _buildToggleOption(2, Icons.pie_chart_rounded, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(int viewIndex, IconData icon, bool isDark) {
    final isSelected = _currentView == viewIndex;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _hoveredView = viewIndex;
            _showHoverIndicator = true;
          });

          // Start timer to hide hover after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted && _hoveredView == viewIndex) {
              setState(() {
                _showHoverIndicator = false;
                _hoveredView = null;
              });
            }
          });
        },
        onExit: (_) {
          setState(() {
            _showHoverIndicator = false;
            _hoveredView = null;
          });
        },
        child: GestureDetector(
          onTap: () {
            _handleViewChange(viewIndex);
          },
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              borderRadius: _getBorderRadiusForOption(viewIndex),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }

  void _handleViewChange(int viewIndex) {
    setState(() {
      _currentView = viewIndex;
      _showHoverIndicator = false;
      _hoveredView = null;
    });

    // Update the viewModel for backward compatibility
    if (viewIndex == 0 || viewIndex == 1) {
      if (widget.viewModel.showIndividualGraphs != (viewIndex == 1)) {
        widget.viewModel.toggleGraphView();
      }
    }

    // Call the callback if provided
    widget.onViewChanged?.call(viewIndex);
  }

  BorderRadius _getBorderRadiusForOption(int index) {
    switch (index) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        );
      case 1:
        return BorderRadius.zero;
      case 2:
        return const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );
      default:
        return BorderRadius.zero;
    }
  }

  BorderRadius _getBorderRadiusForPosition(int index) {
    switch (index) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        );
      case 1:
        return BorderRadius.zero;
      case 2:
        return const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );
      default:
        return BorderRadius.zero;
    }
  }

  LinearGradient _getGradientForView(int viewIndex, bool isDark) {
    switch (viewIndex) {
      case 0:
        return LinearGradient(
          colors: isDark
              ? [Colors.cyan.shade600, Colors.blue.shade600]
              : [Colors.cyan.shade400, Colors.blue.shade400],
        );
      case 1:
        return LinearGradient(
          colors: isDark
              ? [Colors.orange.shade600, Colors.amber.shade600]
              : [Colors.orange.shade400, Colors.amber.shade400],
        );
      case 2:
        return LinearGradient(
          colors: isDark
              ? [Colors.purple.shade600, Colors.pink.shade600]
              : [Colors.purple.shade400, Colors.pink.shade400],
        );
      default:
        return LinearGradient(
          colors: isDark
              ? [Colors.cyan.shade600, Colors.blue.shade600]
              : [Colors.cyan.shade400, Colors.blue.shade400],
        );
    }
  }

  Color _getColorForView(int viewIndex, bool isDark) {
    switch (viewIndex) {
      case 0:
        return isDark ? Colors.cyan.shade600 : Colors.cyan.shade400;
      case 1:
        return isDark ? Colors.orange.shade600 : Colors.orange.shade400;
      case 2:
        return isDark ? Colors.purple.shade600 : Colors.purple.shade400;
      default:
        return isDark ? Colors.cyan.shade600 : Colors.cyan.shade400;
    }
  }
}


// import 'package:AttendanceApp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';

// class GraphToggle extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final Function(int)? onViewChanged;

//   const GraphToggle({super.key, required this.viewModel, this.onViewChanged});

//   @override
//   State<GraphToggle> createState() => _GraphToggleState();
// }

// class _GraphToggleState extends State<GraphToggle> {
//   int _currentView = 0; // 0 = Merged, 1 = Individual, 2 = Project
//   int? _hoveredView;
//   bool _showHoverIndicator = false;

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.white.withOpacity(0.15),
//               Colors.white.withOpacity(0.05),
//             ],
//           ),
//           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Current View Icon
//             _buildViewIcon(),
//             const SizedBox(width: 12),

//             // Three-Way Toggle Switch
//             _buildThreeWayToggle(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildViewIcon() {
//     IconData icon;
//     Color color;

//     switch (_currentView) {
//       case 0:
//         icon = Icons.group;
//         color = Colors.cyan.shade300;
//         break;
//       case 1:
//         icon = Icons.person;
//         color = Colors.orange.shade300;
//         break;
//       case 2:
//         icon = Icons.pie_chart_rounded;
//         color = Colors.purple.shade300;
//         break;
//       default:
//         icon = Icons.group;
//         color = Colors.cyan;
//     }

//     return Icon(icon, size: 18, color: color);
//   }

//   Widget _buildThreeWayToggle() {
//     return Container(
//       width: 80,
//       height: 32,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: Stack(
//         children: [
//           // Background Selection
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 300),
//             left: _currentView * 26.0, // 26px per option
//             child: Container(
//               width: 26,
//               height: 32,
//               decoration: BoxDecoration(
//                 borderRadius: _getBorderRadiusForPosition(_currentView),
//                 gradient: _getGradientForView(_currentView),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _getColorForView(_currentView).withOpacity(0.4),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Hover Indicator
//           if (_showHoverIndicator && _hoveredView != null)
//             AnimatedPositioned(
//               duration: const Duration(milliseconds: 200),
//               left: _hoveredView! * 26.0,
//               child: Container(
//                 width: 26,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   borderRadius: _getBorderRadiusForPosition(_hoveredView!),
//                   border: Border.all(
//                     color: _getColorForView(_hoveredView!).withOpacity(0.8),
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),

//           // Toggle Options
//           Row(
//             children: [
//               _buildToggleOption(0, Icons.group),
//               _buildToggleOption(1, Icons.person),
//               _buildToggleOption(2, Icons.pie_chart_rounded),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleOption(int viewIndex, IconData icon) {
//     final isSelected = _currentView == viewIndex;

//     return Expanded(
//       child: MouseRegion(
//         onEnter: (_) {
//           setState(() {
//             _hoveredView = viewIndex;
//             _showHoverIndicator = true;
//           });

//           // Start timer to hide hover after 5 seconds
//           Future.delayed(const Duration(seconds: 5), () {
//             if (mounted && _hoveredView == viewIndex) {
//               setState(() {
//                 _showHoverIndicator = false;
//                 _hoveredView = null;
//               });
//             }
//           });
//         },
//         onExit: (_) {
//           setState(() {
//             _showHoverIndicator = false;
//             _hoveredView = null;
//           });
//         },
//         child: GestureDetector(
//           onTap: () {
//             _handleViewChange(viewIndex);
//           },
//           child: Container(
//             height: 32,
//             decoration: BoxDecoration(
//               borderRadius: _getBorderRadiusForOption(viewIndex),
//             ),
//             child: Icon(
//               icon,
//               size: 16,
//               color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleViewChange(int viewIndex) {
//     setState(() {
//       _currentView = viewIndex;
//       _showHoverIndicator = false;
//       _hoveredView = null;
//     });

//     // Update the viewModel for backward compatibility
//     if (viewIndex == 0 || viewIndex == 1) {
//       if (widget.viewModel.showIndividualGraphs != (viewIndex == 1)) {
//         widget.viewModel.toggleGraphView();
//       }
//     }

//     // Call the callback if provided
//     widget.onViewChanged?.call(viewIndex);
//   }

//   BorderRadius _getBorderRadiusForOption(int index) {
//     switch (index) {
//       case 0:
//         return const BorderRadius.only(
//           topLeft: Radius.circular(8),
//           bottomLeft: Radius.circular(8),
//         );
//       case 1:
//         return BorderRadius.zero;
//       case 2:
//         return const BorderRadius.only(
//           topRight: Radius.circular(8),
//           bottomRight: Radius.circular(8),
//         );
//       default:
//         return BorderRadius.zero;
//     }
//   }

//   BorderRadius _getBorderRadiusForPosition(int index) {
//     switch (index) {
//       case 0:
//         return const BorderRadius.only(
//           topLeft: Radius.circular(8),
//           bottomLeft: Radius.circular(8),
//         );
//       case 1:
//         return BorderRadius.zero;
//       case 2:
//         return const BorderRadius.only(
//           topRight: Radius.circular(8),
//           bottomRight: Radius.circular(8),
//         );
//       default:
//         return BorderRadius.zero;
//     }
//   }

//   LinearGradient _getGradientForView(int viewIndex) {
//     switch (viewIndex) {
//       case 0:
//         return LinearGradient(
//           colors: [Colors.cyan.shade400, Colors.blue.shade400],
//         );
//       case 1:
//         return LinearGradient(
//           colors: [Colors.orange.shade400, Colors.amber.shade400],
//         );
//       case 2:
//         return LinearGradient(
//           colors: [Colors.purple.shade400, Colors.pink.shade400],
//         );
//       default:
//         return LinearGradient(
//           colors: [Colors.cyan.shade400, Colors.blue.shade400],
//         );
//     }
//   }

//   Color _getColorForView(int viewIndex) {
//     switch (viewIndex) {
//       case 0:
//         return Colors.cyan.shade400;
//       case 1:
//         return Colors.orange.shade400;
//       case 2:
//         return Colors.purple.shade400;
//       default:
//         return Colors.cyan.shade400;
//     }
//   }
// }

