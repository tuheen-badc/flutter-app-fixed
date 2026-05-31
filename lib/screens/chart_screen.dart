// import 'package:flutter/material.dart';
//
// import '../data/models/credit_analytics.dart';
//
// class CreditAnalyticsBarChart extends StatelessWidget {
//   final List<CreditAnalytics> data;
//   final double height;
//
//   const CreditAnalyticsBarChart({
//     Key? key,
//     required this.data,
//     this.height = 120,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (data.isEmpty) {
//       return Container(
//         height: height,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.withOpacity(0.1),
//               Colors.purple.withOpacity(0.1),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Center(
//           child: Text(
//             'No Data Available\n📊',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14, color: Colors.grey),
//           ),
//         ),
//       );
//     }
//
//     // Find max value for scaling
//     final maxValue = data
//         .map((e) => e.total.toDouble())
//         .reduce((a, b) => a > b ? a : b);
//
//     // Calculate Y-axis labels
//     final yAxisLabels = _generateYAxisLabels(maxValue);
//
//     return Container(
//       height: height,
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.blue.withOpacity(0.1),
//             Colors.purple.withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           // Y-axis labels
//           SizedBox(
//             width: 35,
//             child: Column(
//               children: [
//                 // Chart area for Y-axis alignment
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: yAxisLabels.reversed.map((label) {
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 4),
//                         child: Text(
//                           _formatAmount(label),
//                           style: const TextStyle(
//                             fontSize: 8,
//                             fontWeight: FontWeight.w400,
//                             color: Color(0xFF64748B),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 // Space for month labels
//                 const SizedBox(height: 18),
//               ],
//             ),
//           ),
//           // Chart area
//           Expanded(
//             child: Column(
//               children: [
//                 // Bars area
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: data.map((analytics) {
//                       final barHeight = maxValue > 0
//                           ? (analytics.total.toDouble() / maxValue) *
//                                 (height - 50)
//                           : 0.0;
//
//                       return Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 2),
//                           child: Container(
//                             height: barHeight,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.bottomCenter,
//                                 end: Alignment.topCenter,
//                                 colors: [
//                                   Colors.blue.withOpacity(0.8),
//                                   Colors.purple.withOpacity(0.8),
//                                 ],
//                               ),
//                               borderRadius: const BorderRadius.vertical(
//                                 top: Radius.circular(4),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 // Month labels
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: data.map((analytics) {
//                     return Expanded(
//                       child: Text(
//                         _getMonthAbbreviation(analytics.month),
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF64748B),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getMonthAbbreviation(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }
//
//   List<double> _generateYAxisLabels(double maxValue) {
//     // Generate 4-5 evenly spaced labels from 0 to maxValue
//     final labelCount = 4;
//     final step = maxValue / labelCount;
//     return List.generate(labelCount + 1, (index) => step * index);
//   }
//
//   String _formatAmount(double amount) {
//     if (amount >= 1000000) {
//       return '${(amount / 1000000).toStringAsFixed(1)}M';
//     } else if (amount >= 1000) {
//       return '${(amount / 1000).toStringAsFixed(1)}K';
//     } else if (amount == 0) {
//       return '0';
//     } else {
//       return amount.toStringAsFixed(0);
//     }
//   }
// }
