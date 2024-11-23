// import 'package:blade_app/features/collaborator/screens/screens/Leaderboard.dart';
// import 'package:flutter/material.dart';
// import 'HowToEarnPage.dart';

// class CollaboratorHomeHeader extends StatelessWidget {
//   const CollaboratorHomeHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
//     final textColor = isDarkMode ? Colors.white : Colors.black87;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // Weekly Challenge Card
//         Container(
//           padding: const EdgeInsets.all(20.0),
//           margin: const EdgeInsets.all(20.0),
//           decoration: BoxDecoration(
//             color: backgroundColor,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.star, color: Colors.amber, size: 30),
//                   const SizedBox(width: 10),
//                   Text(
//                     "Weekly Challenge",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: textColor,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Earn 500 Points!",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Leaderboard and How to Earn Buttons
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: _buildNavigationButton(
//                   context: context,
//                   icon: Icons.leaderboard,
//                   label: "Leaderboard",
//                   page: const LeaderboardScreen(), // Replace with Leaderboard Page
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildNavigationButton(
//                   context: context,
//                   icon: Icons.local_fire_department,
//                   label: "How to Earn",
//                   page: const HowToEarnPage(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildNavigationButton({
//     required BuildContext context,
//     required IconData icon,
//     required String label,
//     required Widget page,
//   }) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return GestureDetector(
//       onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12.0),
//         decoration: BoxDecoration(
//           color: isDarkMode ? Colors.grey[800] : Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 24, color: Colors.green),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: isDarkMode ? Colors.white : Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
