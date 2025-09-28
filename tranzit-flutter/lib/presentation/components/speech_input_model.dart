import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../infrastructure/providers/speech.provider.dart';

class SpeechInputModal extends StatefulWidget {
  final Function(String) onSpeechResult;

  const SpeechInputModal({
    Key? key,
    required this.onSpeechResult,
  }) : super(key: key);

  @override
  State<SpeechInputModal> createState() => _SpeechInputModalState();
}

class _SpeechInputModalState extends State<SpeechInputModal>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Initialize speech when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpeechProvider>().initializeSpeech();
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _fadeController.forward();
  }

  void _processFinalResult(String recognizedWords) {
    widget.onSpeechResult(recognizedWords);
    Navigator.of(context).pop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Voice query processed: "$recognizedWords"'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    // Reset provider state when modal closes
    context.read<SpeechProvider>().reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechProvider>(
      builder: (context, speechProvider, child) {
        // Control pulse animation based on listening state
        if (speechProvider.isListening && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        } else if (!speechProvider.isListening && _pulseController.isAnimating) {
          _pulseController.stop();
          _pulseController.reset();
        }

        // Show error if exists
        if (speechProvider.errorMessage.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(speechProvider.errorMessage)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
            speechProvider.clearError();
          });
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            height: 350,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Voice Search',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),

                // Status text
                Text(
                  _getStatusText(speechProvider),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Speech text display
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (speechProvider.recognizedWords.isEmpty) ...[
                            Icon(
                              speechProvider.isListening ? Icons.mic : Icons.mic_none,
                              size: 64,
                              color: speechProvider.isListening
                                  ? Colors.red[400]
                                  : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              speechProvider.isListening
                                  ? 'Listening...'
                                  : 'Tap the microphone to start speaking',
                              style: TextStyle(
                                fontSize: 16,
                                color: speechProvider.isListening
                                    ? Colors.red[600]
                                    : Colors.grey[500],
                                fontWeight: speechProvider.isListening
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[

                            Text(
                              speechProvider.recognizedWords,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[800],
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed: () {
                        speechProvider.stopListening();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),

                    // Mic button with animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: speechProvider.isListening ? _pulseAnimation.value : 1.0,
                          child: GestureDetector(
                            onTap: () {
                              if (speechProvider.isListening) {
                                speechProvider.stopListening();
                              } else {
                                speechProvider.startListening();
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _getMicButtonColor(speechProvider),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getMicButtonColor(speechProvider).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _buildMicButtonChild(speechProvider),
                            ),
                          ),
                        );
                      },
                    ),

                    // Done/Use button
                    if (speechProvider.recognizedWords.isNotEmpty && !speechProvider.isListening)
                      TextButton(
                        onPressed: () => _processFinalResult(speechProvider.recognizedWords),
                        child: const Text(
                          'Use Query',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0E4546),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 80),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(SpeechProvider provider) {
    if (!provider.isInitialized) return 'Initializing speech recognition...';
    if (!provider.speechEnabled) return 'Speech recognition not available';
    if (provider.isListening) return 'Listening... Speak your query now';
    if (provider.recognizedWords.isNotEmpty) return 'Tap "Use Query" to search';
    return 'Tap microphone to Book your ride in Instant';
  }

  Color _getMicButtonColor(SpeechProvider provider) {
    if (!provider.speechEnabled || !provider.isInitialized) return Colors.grey;
    if (provider.isListening) return Colors.red[600]!;
    return const Color(0xFF0E4546);
  }

  Widget _buildMicButtonChild(SpeechProvider provider) {
    if (!provider.isInitialized) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Icon(
      provider.isListening ? Icons.stop : Icons.mic,
      color: Colors.white,
      size: 32,
    );
  }
}