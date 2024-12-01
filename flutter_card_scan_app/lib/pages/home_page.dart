import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_scan_app/controllers/camera_controller.dart';
import 'package:flutter_card_scan_app/controllers/number_detection_controller.dart';
import 'package:flutter_card_scan_app/pages/widgets/camera_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NumberDetectionController numberDetectionController = NumberDetectionController();
  String? cardNumber;
  bool isCamOpen = false;
  Uint8List? imageToDectect;

  CamController camController = CamController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Visibility(
                visible: isCamOpen,
                child: Container(
                    padding: const EdgeInsets.only(bottom: 49),
                    child: CameraPreviewWidget(camController: camController))
            ),
            Visibility(
              visible: cardNumber != null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  ),
                ),
                child: Text(cardNumber ?? ''),
              )
            ),
            const SizedBox(height: 40),
            // if(imageToDectect!=null)
            //   Image.memory(imageToDectect!, height: 200, width: 300),
            // if(imageToDectect==null) const Text("not found image"),
            // const SizedBox(height: 40),
            ElevatedButton(
              child: Text(!isCamOpen ? "Quét thẻ" : "Dừng quét"),
              onPressed: () async {
                await initCamera();

                setState(() {
                  isCamOpen = !isCamOpen;
                });

                await Future.delayed(const Duration(milliseconds: 2000));
                
                camController.frameProcess((imageFrame) async {
                  imageToDectect = await camController.cameraImageToFile(imageFrame);
                  setState(() {});
                });

                // String? imagePath = await numberDetectionController.pickImage();
                // if (imagePath != null) {
                //   cardNumber =
                //       await numberDetectionController.recognizeNumber(imagePath);
                //   setState(() {});
                // }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initCamera() async {
    await camController.initCamera();
  }
}