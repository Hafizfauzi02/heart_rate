import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Heartratehome extends StatefulWidget {
  const Heartratehome({super.key});

  @override
  State<Heartratehome> createState() => _HeartratehomeState();
}

class _HeartratehomeState extends State<Heartratehome> {
  late Interpreter _interpreter;
  double _heartRate = 70;
  String _prediction = "Unknown";
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("heart_rate_model.tflite");
      setState(() {
        _modelLoaded = true;
      });
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  void predict(double hr) {
    if (!_modelLoaded) {
      print("Model not loaded yet");
      return;
    }
    final input = [hr / 140]; // normalize same as training
    var output = List.filled(3, 0.0).reshape([1, 3]);
    _interpreter.run([input], output);

    int index = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
    List<String> labels = ["Dangerous", "Low", "Safe"]; // order from training

    setState(() {
      _prediction = labels[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Heart Rate AI")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Enter Heart Rate:"),
            Slider(
              value: _heartRate,
              min: 40,
              max: 140,
              divisions: 100,
              label: _heartRate.round().toString(),
              onChanged: (value) {
                setState(() {
                  _heartRate = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () => predict(_heartRate),
              child: Text("Check Status"),
            ),
            SizedBox(height: 20),
            Text("Prediction: $_prediction", style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
