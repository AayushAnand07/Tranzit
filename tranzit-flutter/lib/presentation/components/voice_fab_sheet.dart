import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceFabExample extends StatefulWidget {
  @override
  _VoiceFabExampleState createState() => _VoiceFabExampleState();
}

class _VoiceFabExampleState extends State<VoiceFabExample> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Say something...";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (!available) {
      setState(() => _text = "Speech recognition not available");
      return;
    }

    setState(() {
      _isListening = true;
      _text = "";
    });

    _speech.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _openVoiceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Full screen if needed
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isListening ? "Listening..." : "Press mic to start",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                _text,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: _isListening ? _stopListening : _startListening,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Voice Search Demo")),
      floatingActionButton: FloatingActionButton.large(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: Color(0x605CFFFE),
        child: Icon(Icons.mic, color: Colors.white),
        onPressed: _openVoiceSheet,
      ),
      body: Center(child: Text("Press the mic button to start voice query")),
    );
  }
}
