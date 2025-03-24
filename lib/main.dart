// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// void main() {
//   runApp(EWasteApp());
// }

// class EWasteApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'EcoByte',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         fontFamily: 'medieval',
//       ),
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Gradient Background
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF4a8703), Color(0xFF122201)], // Leaf-inspired colors
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),

//           // Lottie Animation Layer (Above Gradient)
//           SizedBox.expand(
//             child: Lottie.asset(
//               'assets/leaves.json',
//               fit: BoxFit.cover,
//               repeat: true, // Loop animation continuously
//             ),
//           ),

//           // Foreground Content
//           Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min, // Centers the content vertically
//               children: [
//                 Text(
//                   'EcoByte',
//                   style: TextStyle(
//                     fontSize: 40,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'Help your home be safer',
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: Colors.white70,
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Navigate to Sign In Page
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: Color(0xFF52734D), // Leaf-inspired color
//                   ),
//                   child: Text('Sign In'),
//                 ),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Navigate to Sign Up Page
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: Color(0xFF52734D), // Leaf-inspired color
//                   ),
//                   child: Text('Sign Up'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart'; 
import 'dart:io' show Platform;  
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(EWasteApp());
}

class EWasteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoByte',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.ralewayTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: HomePage(), // Set HomePage as the main screen
    );
  }
}
