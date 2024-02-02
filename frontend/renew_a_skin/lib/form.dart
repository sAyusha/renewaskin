import 'package:flutter/material.dart';
import 'package:renew_a_skin/recommendation.dart';

class MyFormPage extends StatefulWidget {
  final String skinTone;
  final String predictedSkinType;

  // Declare a GlobalKey for the MyFormPage state
  static final GlobalKey<MyFormPageState> formKey =
      GlobalKey<MyFormPageState>();
  const MyFormPage({
    Key? key,
    required this.skinTone,
    required this.predictedSkinType,
  }) : super(key: key);

  @override
  MyFormPageState createState() => MyFormPageState();
}

class MyFormPageState extends State<MyFormPage> {
  String selectedTone = '5';
  List<String> selectedSkinConcerns = [];

  final List<Map<String, dynamic>> toneOptions = [
    {'value': '1', 'color': const Color(0x0ffd5524)},
    {'value': '2', 'color': const Color(0xFFc68642)},
    {'value': '3', 'color': const Color(0xFFe0ac69)},
    {'value': '4', 'color': const Color(0xFFf1c27d)},
    {'value': '5', 'color': const Color(0xffffdbac)},
  ];

  final List<String> skinConcernOptions = [
    'sensitive',
    'fine lines',
    'wrinkles',
    'redness',
    'pore',
    'pigmentation',
    'blackheads',
    'whiteheads',
    'blemishes',
    'dark circles',
    'eye bags',
    'dark spots'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 242, 186),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 242, 186),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Other Concerns',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: const InputDecoration(
                  labelText: 'Skin Tone',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                value: toneOptions
                    .firstWhere((element) => element['value'] == selectedTone),
                items: toneOptions.map((tone) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: tone,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: tone['color'],
                        ),
                        const SizedBox(width: 8),
                        Text('Skin Tone: ${widget.skinTone}'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTone = value!['value'] as String;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              const SizedBox(height: 16.0),
              // const SizedBox(height: 16.0),
              ListTile(
                title: const Text(
                  'Specify Other Skin Concerns',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                subtitle: SizedBox(
                  height: 500.0,
                  child: ListView.builder(
                    itemCount: skinConcernOptions.length,
                    itemBuilder: (context, index) {
                      final concern = skinConcernOptions[index];
                      return CheckboxListTile(
                        title: Text(
                          concern,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        value: selectedSkinConcerns.contains(concern),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              selectedSkinConcerns.add(concern);
                            } else {
                              selectedSkinConcerns.remove(concern);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle form submission
                    // Access selectedTone and selectedSkinConcerns for further processing
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SkinProductPage(
                                predictedSkinType: widget.predictedSkinType,
                                selectedSkinConcerns: selectedSkinConcerns,
                              )),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 66, 65, 65),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 18
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
