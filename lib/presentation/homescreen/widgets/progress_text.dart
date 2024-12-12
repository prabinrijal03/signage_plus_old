// import 'package:flutter/material.dart';

// import '../../../services/utils.dart';

// class DownloadProgressText extends StatefulWidget {
//   const DownloadProgressText({super.key});

//   @override
//   State<DownloadProgressText> createState() => DownloadProgressTextState();
// }

// class DownloadProgressTextState extends State<DownloadProgressText> {
//   String progressInfo = '';
//   @override
//   void initState() {
//     super.initState();
//     Utils.downloadProgressStream.listen((event) {
//       setState(() {
//         progressInfo = event;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       progressInfo,
//       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//     );
//   }
// }
