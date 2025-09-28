import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ImprovedSpeechWidget extends StatefulWidget {
  final Function(String) onSpeechResult;
  final VoidCallback? onListeningStart;
  final VoidCallback? onListeningStop;

  const ImprovedSpeechWidget({
    Key? key,
    required this.onSpeechResult,
    this.onListeningStart,
    this.onListeningStop,
  }) : super(key: key);

  @override
  State<ImprovedSpeechWidget> createState() => _ImprovedSpeechWidgetState();
}

class _ImprovedSpeechWidgetState extends State<ImprovedSpeechWidget>
    with SingleTickerProviderStateMixin {
  late SpeechToText _speechToText;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _speechEnabled = false;
  bool _isListening = false;
  String _currentWords = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initSpeech();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initSpeech() async {
    if (_isInitialized) return;

    try {
      _speechToText = SpeechToText();
      bool available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: false, // Disable debug logging for better performance
      );

      if (mounted) {
        setState(() {
          _speechEnabled = available;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _speechEnabled = false;
          _isInitialized = true;
        });
        _showError('Failed to initialize speech recognition');
      }
    }
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;

    final bool wasListening = _isListening;
    final bool isListening = status == 'listening';

    setState(() {
      _isListening = isListening;
    });

    if (isListening && !wasListening) {
      _animationController.repeat(reverse: true);
      widget.onListeningStart?.call();
    } else if (!isListening && wasListening) {
      _animationController.stop();
      _animationController.reset();
      widget.onListeningStop?.call();
    }
  }

  void _onSpeechError(dynamic error) {
    if (!mounted) return;

    setState(() {
      _isListening = false;
    });

    _animationController.stop();
    _animationController.reset();

    String errorMessage = 'Speech recognition error';
    if (error.toString().contains('network')) {
      errorMessage = 'Network error. Please check your connection.';
    } else if (error.toString().contains('permission')) {
      errorMessage = 'Microphone permission required';
    }

    _showError(errorMessage);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;

    setState(() {
      _currentWords = result.recognizedWords;
    });

    // Check word limit
    final wordCount = _currentWords.trim().split(' ').length;
    if (wordCount > 20) {
      _stopListening();
      _showError('Query too long. Please limit to 20 words.');
      return;
    }

    // If final result, process it
    if (result.finalResult && _currentWords.trim().isNotEmpty) {
      widget.onSpeechResult(_currentWords);
      setState(() {
        _currentWords = '';
      });
    }
  }

  Future<void> _startListening() async {
    if (!_speechEnabled || !_isInitialized) {
      _showError('Speech recognition not available');
      return;
    }

    if (_isListening) return;

    setState(() {
      _currentWords = '';
    });

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 2),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      _showError('Failed to start listening');
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
    } catch (e) {
      // Ignore stop errors
    }

    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _scaleAnimation.value : 1.0,
          child: Opacity(
            opacity: _isListening ? _opacityAnimation.value : 1.0,
            child: FloatingActionButton(
              onPressed: _isListening ? _stopListening : _startListening,
              backgroundColor: _getButtonColor(),
              elevation: _isListening ? 12 : 6,
              heroTag: "speech_fab", // Prevent hero tag conflicts
              child: _buildButtonChild(),
            ),
          ),
        );
      },
    );
  }

  Color _getButtonColor() {
    if (!_speechEnabled) return Colors.grey;
    if (_isListening) return Colors.red.shade600;
    return Theme.of(context).primaryColor;
  }

  Widget _buildButtonChild() {
    if (!_isInitialized) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (!_speechEnabled) {
      return const Icon(
        Icons.mic_off,
        color: Colors.white,
        size: 28,
      );
    }

    return Icon(
      _isListening ? Icons.stop : Icons.mic,
      color: Colors.white,
      size: 28,
    );
  }
}