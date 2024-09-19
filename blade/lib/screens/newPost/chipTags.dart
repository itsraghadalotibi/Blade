// import 'package:flutter/material.dart';
// import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';

// class FlutterChipsTags extends StatefulWidget {
//   @override
//   _FlutterChipsTagsState createState() => _FlutterChipsTagsState();
// }

// class _FlutterChipsTagsState extends State<FlutterChipsTags> {
//   List<String> tags = [];
//   List<String> options = [
//     'React',
//     'Frontend Developer',
//     'Backend Developer',
//     'UI/UX',
//     'Mern Stack',
//     'Flutter',
//     'Web',
//     'AI'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: ChipsChoice<String>.multiple(
//         value: tags,
//         onChanged: (val) => setState(() => tags = val),
//         choiceItems: C2Choice.listFrom(
//           source: options,
//           value: (i, v) => v,
//           label: (i, v) => v,
//         ),
//         choiceActiveStyle: const C2ChoiceStyle(
//           color: Colors.orange,
//           borderColor: Colors.grey,
//           borderRadius: BorderRadius.all(
//             Radius.circular(10),
//           ),
//         ),
//         choiceStyle: const C2ChoiceStyle(
//           color: Colors.black,
//           borderRadius: BorderRadius.all(
//             Radius.circular(10),
//           ),
//         ),
//         wrapped: true,
//       ),
//     );
//   }
// }
