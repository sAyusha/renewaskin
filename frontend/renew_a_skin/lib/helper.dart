import 'package:flutter/material.dart';

class HelperPage extends StatelessWidget {
  const HelperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 242, 186),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 242, 186),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'How to use the renewaskin app?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
      body: const Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. Take or upload an image using the provided buttons.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              '2. View the skin analysis report and click "OK".',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              '3. Click "Process Image" for further analysis.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              '4. Fill up the form with other acne concerns in the checkbox list.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              '5. Choose your skin tone if the result is not accurate.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              '6. Click "Submit".',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              '7. Receive skincare product recommendations based on the analysis report.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
