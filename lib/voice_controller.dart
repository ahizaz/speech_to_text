
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  var available = false.obs;
  var isListening = false.obs;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();

  Rx<TextEditingController?> selectedField = Rx<TextEditingController?>(null);

  @override
  void onInit() {
    super.onInit();
    initSpeech();
  }

  Future<void> initSpeech() async {
    available.value = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          isListening.value = false;
        }
      },
      onError: (error) {
        isListening.value = false;
        Get.snackbar('Error', 'Speech recognition error: ${error.errorMsg}',
            snackPosition: SnackPosition.BOTTOM);
      },
    );
  }

  Future<void> startListen() async {
    if (!available.value || selectedField.value == null) {
      Get.snackbar('Warning', 'Select a text field first',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isListening.value = true;

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _updateSelectedField(result.recognizedWords);
        }
      },
      listenMode: stt.ListenMode.dictation,
      pauseFor: const Duration(seconds: 5), // Reduced to avoid capturing noise
      listenFor: const Duration(minutes: 10),
      localeId: "en_US",
      partialResults: true, // Enable partial results for better detection
      cancelOnError: true, // Cancel on errors to avoid noise-induced issues
      sampleRate: 44100, // Higher sample rate for better audio quality
    );
  }

  void stopListen() {
    _speech.stop();
    isListening.value = false;
  }

  void _updateSelectedField(String text) {
    final field = selectedField.value;
    if (field != null && text.trim().isNotEmpty) {
      // Append only non-empty, valid text
      String currentText = field.text;
      field.text = currentText.isEmpty ? text : '$currentText $text';
      field.selection = TextSelection.fromPosition(
        TextPosition(offset: field.text.length),
      );
    }
  }
}