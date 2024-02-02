import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:renew_a_skin/form.dart';
import 'package:renew_a_skin/helper.dart';
import 'package:renew_a_skin/recommendation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  late Interpreter _interpreter;
  late Interpreter _interpreter2;
  late ImageProcessor _imageProcessor;
  img.Image? _pickedImage;
  late String _predictedSkinType;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _imageProcessor = ImageProcessorBuilder().build();
  }

  void _loadModel() async {
    final interpreterOptions = InterpreterOptions();
    _interpreter = await Interpreter.fromAsset(
        'assets/skintype_trained_model.tflite',
        options: interpreterOptions);
    _interpreter2 = await Interpreter.fromAsset(
        'assets/acnetrained_model.tflite',
        options: interpreterOptions);
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _pickedImage =
            img.decodeImage(Uint8List.fromList(_imageFile!.readAsBytesSync()));
      });

      _classifyImage(pickedFile);
    }
  }

  Future<void> _classifyImage(XFile image) async {
    const inputSize = 200;
    final rawImage = await image.readAsBytes();
    final inputImage = img.decodeImage(Uint8List.fromList(rawImage))!;

    final resizedImage =
        img.copyResize(inputImage, width: inputSize, height: inputSize);
    final normalizedImage = resizedImage.getBytes();

    const batchSize = 1;
    const inputChannels = 3;
    final inputImageData =
        Float32List(batchSize * inputSize * inputSize * inputChannels);

    for (var i = 0; i < inputSize * inputSize; i++) {
      inputImageData[i * 3 + 0] = normalizedImage[i * 3] / 255.0;
      inputImageData[i * 3 + 1] = normalizedImage[i * 3 + 1] / 255.0;
      inputImageData[i * 3 + 2] = normalizedImage[i * 3 + 2] / 255.0;
    }

    print(
        'Input Tensor Shape (Skin Type Model): ${_interpreter.getInputTensor(0).shape}');

    final skinTypeOutputShape = _interpreter.getOutputTensor(0).shape;
    final skinTypeOutputSize = skinTypeOutputShape.reduce((a, b) => a * b);
    final skinTypeOutput = Float32List(skinTypeOutputSize);

    try {
      _interpreter.run(inputImageData.buffer.asUint8List(),
          skinTypeOutput.buffer.asUint8List());
    } catch (e) {
      print("Error running skin type inference: $e");
      return;
    }

    final skinTypeResult =
        skinTypeOutput.indexOf(skinTypeOutput.reduce((a, b) => a > b ? a : b));
    final skinTypeLabels = ['dry', 'normal', 'oily'];
    _predictedSkinType = skinTypeLabels[skinTypeResult];

    final acneLevelOutputShape = _interpreter2.getOutputTensor(0).shape;
    final acneLevelOutputSize = acneLevelOutputShape.reduce((a, b) => a * b);
    final acneLevelOutput = Float32List(acneLevelOutputSize);

    try {
      _interpreter2.run(inputImageData.buffer.asUint8List(),
          acneLevelOutput.buffer.asUint8List());
    } catch (e) {
      print("Error running acne level inference: $e");
      return;
    }

    final acneLevelResult = acneLevelOutput
        .indexOf(acneLevelOutput.reduce((a, b) => a > b ? a : b));
    final acneLevelLabels = ['Low', 'Moderate', 'Severe'];
    String acneLevel = acneLevelLabels[acneLevelResult];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Skin Analysis Result',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Predicted Skin Type: $_predictedSkinType',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Predicted Acne Level: $acneLevel',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 242, 186),
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/renewaskin_logo.png',
                    width: 50.0,
                    height: 50.0,
                  ),
                  const Text(
                    'Renewaskin',
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              _imageFile == null
                  ? Container(
                      width: 350.0,
                      height: 350.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xff4d4d4d).withOpacity(0.2)),
                      ),
                      child: const Center(
                        child: Text('Upload/Capture the image selected',
                            style: TextStyle(
                              fontSize: 18.0,
                            )),
                      ),
                    )
                  : Container(
                      width: 350.0,
                      height: 350.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xff4d4d4d).withOpacity(0.2)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _imageFile!,
                          width: 350.0,
                          height: 450.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              const SizedBox(height: 30.0),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _getImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 65, 65, 66),
                          ),
                          child: const Text(
                            'Capture Image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _getImage(ImageSource.gallery),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 66, 65, 65),
                          ),
                          child: const Text(
                            'Upload Image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      height: 50,
                      width: 350,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Make HTTP request to the Flask backend
                          String backendUrl =
                              'http://10.0.2.2:3001/'; // Replace with your backend URL

                          // Ensure _imageFile is not null before proceeding
                          if (_imageFile != null) {
                            try {
                              // Convert the image file to bytes
                              List<int> imageBytes =
                                  await _imageFile!.readAsBytes();

                              // Encode the image bytes to base64
                              String base64Image = base64Encode(imageBytes);

                              // Send the base64-encoded image data to the backend
                              var response = await http.put(
                                Uri.parse('$backendUrl/upload'),
                                body: {'file': base64Image},
                              );

                              if (response.statusCode == 200) {
                                // Successfully received skin tone information
                                var skinTone =
                                    json.decode(response.body)['tone'];
                                print('Skin Tone: $skinTone');

                                // Navigate to the form screen with skin tone data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyFormPage(
                                      skinTone: skinTone,
                                      predictedSkinType: _predictedSkinType,
                                    ),
                                  ),
                                );
                              } else {
                                // Handle error
                                print(
                                    'Failed to fetch skin tone data. Status code: ${response.statusCode}');
                              }
                            } catch (e) {
                              // Handle exception
                              print('Exception: $e');
                            }
                          } else {
                            // Handle the case where _imageFile is null (no image selected/uploaded)
                            // Show SnackBar if no image is selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'No image selected',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            print('No image selected/uploaded');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 66, 65, 65),
                        ),
                        child: const Text(
                          'Process Image',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HelperPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Help Me',
                        style: TextStyle(
                          color: Color.fromARGB(255, 2, 90, 161),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
