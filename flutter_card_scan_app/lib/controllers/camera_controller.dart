import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CamController{
  CameraController? controller;
  late Future<void> initializeControllerFuture;

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final mainCamera = cameras.first;

    controller = CameraController(
      mainCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    initializeControllerFuture = controller!.initialize();
  }

  void frameProcess(Function(CameraImage) imageFramceProcessLogic){
    DateTime? lastProcessedTime;
    controller!.startImageStream((CameraImage image) async {
      final now = DateTime.now();
      if (lastProcessedTime == null || now.difference(lastProcessedTime!).inSeconds >= 1) {
        lastProcessedTime = now;
        imageFramceProcessLogic(image);
      }
    });

  }

  void dispose() {
    controller?.dispose();
  }

  Future<Uint8List> cameraImageToFile(CameraImage cameraImage) async {
    final img.Image convertedImage = convertYUV420ToImage(cameraImage);
    final Uint8List bytes = Uint8List.fromList(img.encodeJpg(convertedImage));

    // print('checkbyte');
    // final Directory tempDir = await getTemporaryDirectory();
    // final String filePath = '${tempDir.path}/camera_image.png';
    // File file = await File(filePath);
    // await file.writeAsBytes(bytes);

    return bytes;
  }

  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final img.Image image = img.Image(width: width, height: height);

    final Plane yPlane = cameraImage.planes[0];
    final Plane uPlane = cameraImage.planes[1];
    final Plane vPlane = cameraImage.planes[2];

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * cameraImage.planes[0].bytesPerRow + x;

        final int uvIndex = uvRowStride * (y ~/ 2) + (x ~/ 2) * uvPixelStride;

        final int yValue = yPlane.bytes[yIndex];
        final int uValue = uPlane.bytes[uvIndex];
        final int vValue = vPlane.bytes[uvIndex];

        final int r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        final int g = (yValue -
                0.344136 * (uValue - 128) -
                0.714136 * (vValue - 128))
            .clamp(0, 255)
            .toInt();
        final int b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

        image.setPixelRgb(x, y, r, g, b);
      }
    }

    return img.copyRotate(image, angle: 90);
  }
}