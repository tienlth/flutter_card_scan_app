import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_scan_app/controllers/camera_controller.dart';

class CameraPreviewWidget extends StatefulWidget {
  CamController? camController;
  CameraPreviewWidget({required this.camController,super.key});
  
  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 300,
      padding: const EdgeInsets.all(8),
      child: 
        FutureBuilder(
          future: widget.camController!.initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(widget.camController!.controller!);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        )
    );
  }

  @override
  void dispose() {
    widget.camController!.dispose();
    super.dispose();
  }

}