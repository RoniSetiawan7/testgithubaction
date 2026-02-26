import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

  void main() {
    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OcrPage(),
      );
    }
  }

  class OcrPage extends StatefulWidget {
    @override
    State<OcrPage> createState() => _OcrPageState();
  }

  class _OcrPageState extends State<OcrPage> {
    File? _image;
    String _resultText = '';
    bool _loading = false;

    final String apiKey = 'FcH3GeYeTHBtY4aVPaBDRi5vCXUctnJ1S2tHr7FWPpZ1'; // ganti dengan API Key Optiic kamu
    final String ocrUrl = 'https://api.optiic.dev/process';

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() {
          _image = File(picked.path);
          _resultText = '';
        });
      }
    }

    Future<void> runOcr() async {
      if (_image == null) return;

      setState(() => _loading = true);

      try {
        // Dio dio = Dio();

        // FormData formData = FormData.fromMap({
        //   'apiKey': apiKey,
        //   'image': await MultipartFile.fromFile(_image!.path, filename: _image!.path.split('/').last),
        //   // Kadang backend butuh ini
        //   'event_source': 'flutter',
        // });

        // Response response = await dio.post(
        //   ocrUrl,
        //   data: formData,
        //   options: Options(
        //     headers: {
        //       'Accept': 'application/json',
        //     },
        //   ),
        // );

        Dio dio = Dio();

        FormData formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            _image!.path,
            filename: _image!.path.split('/').last
          ),
        });

        Response response = await dio.post(
          ocrUrl,
          data: formData,
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $apiKey', // <-- move API key here
            },
          ),
        );


        print('STATUS: ${response.statusCode}');
        print('BODY: ${response.data}');

        if (response.statusCode == 200) {
          setState(() {
            _resultText = response.data['text'] ?? 'Tidak ada teks terdeteksi';
          });
        } else {
          setState(() {
            _resultText = 'Gagal OCR (${response.statusCode})';
          });
        }
      } catch (e) {
        setState(() {
          _resultText = 'Error: $e';
        });
      }

      setState(() => _loading = false);
    }

    @override
    Widget build(BuildContext context) {
      print('Result Text: $_resultText');
      return Scaffold(
        appBar: AppBar(title: const Text('OCR OpticAPI')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_image != null)
                Image.file(_image!, height: 200),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Ambil Gambar'),
              ),

              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: _loading ? null : runOcr,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Scan OCR'),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _resultText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

// import 'dart:io';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: OcrPage(),
//     );
//   }
// }

// class OcrPage extends StatefulWidget {
//   @override
//   State<OcrPage> createState() => _OcrPageState();
// }

// class _OcrPageState extends State<OcrPage> {
//   File? _image;
//   String _resultText = '';
//   bool _loading = false;

//   // ====== KONFIGURASI OPTICAPI ======
//   final String apiKey = 'FcH3GeYeTHBtY4aVPaBDRi5vCXUctnJ1S2tHr7FWPpZ1';
//   final String ocrUrl = 'https://api.optiic.dev/process';
//   // ⚠️ ganti sesuai endpoint OpticAPI
//   // =================================

//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);

//     if (picked != null) {
//       setState(() {
//         _image = File(picked.path);
//         _resultText = '';
//       });
//     }
//   }

//   Future<void> runOcr() async {
//     if (_image == null) return;

//     setState(() => _loading = true);

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://api.optiic.dev/process'),
//       );

//       // ✅ API KEY WAJIB di form-data
//       request.fields['apiKey'] = apiKey;

//       // 🔥 WORKAROUND BUG BACKEND
//       request.fields['event_source'] = 'flutter';

//       // ✅ file name harus "image"
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'image',
//           _image!.path,
//         ),
//       );

//       final response = await request.send();
//       final body = await response.stream.bytesToString();

//       print('STATUS: ${response.statusCode}');
//       print('BODY: $body');

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(body);
//         setState(() {
//           _resultText = jsonData['text'] ?? 'Tidak ada teks terdeteksi';
//         });
//       } else {
//         setState(() {
//           _resultText = 'Gagal OCR (${response.statusCode})';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _resultText = 'Error: $e';
//       });
//     }

//     setState(() => _loading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('OCR OpticAPI')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             if (_image != null)
//               Image.file(_image!, height: 200),

//             const SizedBox(height: 16),

//             ElevatedButton(
//               onPressed: pickImage,
//               child: const Text('Ambil Gambar'),
//             ),

//             const SizedBox(height: 8),

//             ElevatedButton(
//               onPressed: _loading ? null : runOcr,
//               child: _loading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Scan OCR'),
//             ),

//             const SizedBox(height: 16),

//             Expanded(
//               child: SingleChildScrollView(
//                 child: Text(
//                   _resultText,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
