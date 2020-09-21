import 'package:flutter/material.dart';

class Camera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Camera screen'),
      ),
    );
  }
}






// import 'package:camera/camera.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';
// import 'dart:async';
// import 'dart:io';


// // A screen that allows users to take a picture using a given camera.
// class TakePictureScreen extends StatefulWidget {
//   final CameraDescription camera;
//   final List camAvailable;
//   const TakePictureScreen({
//     Key key,
//     @required this.camera,
//     this.camAvailable,
//   }) : super(key: key);

//   @override
//   TakePictureScreenState createState() => TakePictureScreenState();
// }

// class TakePictureScreenState extends State<TakePictureScreen> {
//   CameraController _controller;
//   Future<void> _initializeControllerFuture;
//   CameraDescription cam;

//   @override
//   void initState() {
//     super.initState();
//     _controller = CameraController(widget.camera , ResolutionPreset.medium); 
//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed.
//     _controller.dispose();
//     super.dispose();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return CameraPreview(_controller);
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       bottomNavigationBar: Row(
//         children: [
//           Expanded(
//           child: FlatButton(
//           onPressed: (){

//           },
//           child: Icon(Icons.flash_off),
//           ),
//           ),
//           Expanded(
//           child: FlatButton(
//             child: Icon(Icons.camera_alt),
         
//             onPressed: () async {

//               print(widget.camAvailable);
//               try {
//                 await _initializeControllerFuture;
//                 final path = join(
//                   (await getTemporaryDirectory()).path,
//                   '${DateTime.now()}.png',
//                 );
//                 await _controller.takePicture(path);

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => DisplayPictureScreen(imagePath: path),
//                   ),
//                 );
//               } catch (e) {
//                 print(e);
//               }
//             },
//             ),
//           ),        
//            Expanded(
//               child: FlatButton(
//               onPressed: (){},
//              child: Icon(Icons.switch_camera),),
//            )
//         ],
//       ),
//     );
//   }
// }

// // A widget that displays the picture taken by the user.
// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;

//   const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // The image is stored as a file on the device. Use the `Image.file`
//       // constructor with the given path to display the image.
//       body: Image.file(File(imagePath)),
//       floatingActionButton: FloatingActionButton(
//         onPressed: (){

//         },
//         child: Icon(Icons.check),
//         ),
//     );
//   }
// }
