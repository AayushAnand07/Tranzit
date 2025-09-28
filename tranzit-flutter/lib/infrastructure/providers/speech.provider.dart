import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tranzit/infrastructure/services/chat.service.dart';

class SpeechProvider with ChangeNotifier {
  late SpeechToText _speechToText;
final ChatService _chatService = ChatService();
  bool _isInitialized = false;
  bool _speechEnabled = false;
  bool _isListening = false;
  String _recognizedWords = '';
  int _wordCount = 0;
  String _errorMessage = '';


  bool get isInitialized => _isInitialized;
  bool get speechEnabled => _speechEnabled;
  bool get isListening => _isListening;
  String get recognizedWords => _recognizedWords;
  int get wordCount => _wordCount;
  String get errorMessage => _errorMessage;

  Future<void> initializeSpeech() async {
    if (_isInitialized) return;

    try {
      _speechToText = SpeechToText();
      bool available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: false,
      );

      _speechEnabled = available;
      _isInitialized = true;
      _errorMessage = '';
      notifyListeners();

    } catch (e) {
      _speechEnabled = false;
      _isInitialized = true;
      _errorMessage = 'Speech recognition initialization failed';
      notifyListeners();
    }
  }

  void _onSpeechStatus(String status) {
    final wasListening = _isListening;
    _isListening = status == 'listening';

    if (wasListening != _isListening) {
      notifyListeners();
    }
  }

  void _onSpeechError(dynamic error) {
    _isListening = false;
    _errorMessage = 'Speech recognition error occurred';
    notifyListeners();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim().split(' ');
    final wordCount = words.where((word) => word.isNotEmpty).length;

    _recognizedWords = result.recognizedWords;
    _wordCount = wordCount;

    if (wordCount > 20) {
      stopListening();
      _errorMessage = 'Query too long! Please limit to 20 words or less.';
    } else {
      _errorMessage = '';
    }

    notifyListeners();
  }


  Future<void> startListening() async {
    if (!_speechEnabled || !_isInitialized || _isListening) return;

    _recognizedWords = '';
    _wordCount = 0;
    _errorMessage = '';
    notifyListeners();

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      _errorMessage = 'Failed to start listening';
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void>postSpeechForProcessing(String query,String token)async{
      try{
        await _chatService.postQueryForProcessing(query,token);
      }
      catch(e){
        print("Error posting query: $e");
      }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
    } catch (e) {

    }


    _isListening = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void reset() {
    _recognizedWords = '';
    _wordCount = 0;
    _errorMessage = '';
    _isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _speechToText.stop();
    }
    super.dispose();
  }
}