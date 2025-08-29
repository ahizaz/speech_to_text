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

  // কোন TextField সিলেক্টেড সেটা ট্র্যাক করার জন্য
  Rx<TextEditingController?> selectedField = Rx<TextEditingController?>(null);

  @override
  void onInit() {
    super.onInit();
    initSpeech();
  }

  Future<void> initSpeech() async {
    available.value = await _speech.initialize(
      onStatus: (status) {
        if (status == "done") {
          isListening.value = false;
        }
      },
      onError: (error) {
        isListening.value = false;
      },
    );
  }

  Future<void> startListen() async {
    if (!available.value || selectedField.value == null) return;

    isListening.value = true;

    await _speech.listen(
      onResult: (result) {
        _updateSelectedField(result.recognizedWords);
      },
      listenMode: stt.ListenMode.dictation,
      pauseFor: const Duration(seconds: 10),
      listenFor: const Duration(minutes: 5), // long duration = stop না করা পর্যন্ত চলবে
      localeId: "en_US", // চাইলে "bn_BD"
    );
  }

  void stopListen() {
    _speech.stop();
    isListening.value = false;
  }

  void _updateSelectedField(String text) {
    final field = selectedField.value;
    if (field != null) {
      field.text = text;
      field.selection = TextSelection.fromPosition(
        TextPosition(offset: field.text.length),
      );
    }
  }
}
