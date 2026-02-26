import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:mnc_identifier_ocr/mnc_identifier_ocr.dart';
import 'package:mnc_identifier_ocr/model/ocr_result_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  OcrResultModel? result;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanKtp() async {
    OcrResultModel? res;
    try {
      res = await MncIdentifierOcr.startCaptureKtp(
          withFlash: true, cameraOnly: true);
    } catch (e) {
      debugPrint('something goes wrong $e');
    }

    if (!mounted) return;

    setState(() {
      result = res;
    });
  }

  _imgGlr() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    debugPrint('path: ${image?.path}');
  }

  _imgCmr() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera);
    debugPrint('path: ${image?.path}');
  }

  Future<void> pickAndScanKtp() async {
    try {
      final XFile? image =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      // kirim path ke OCR
      final OcrResultModel? res =
          await MncIdentifierOcr.scanKtpFromFile(image.path);

      if (!mounted) return;

      setState(() {
        result = res;
      });

    } catch (e) {
      debugPrint('error scan ktp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(
          children: [
            Text('Ktp data: ${result?.toJson()}'),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: pickAndScanKtp, child: const Text('PUSH HERE')),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _imgCmr, child: Text('CAMERA')),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _imgGlr, child: Text('GALLERY')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}