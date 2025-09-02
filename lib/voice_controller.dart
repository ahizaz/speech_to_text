
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class SpeechController extends GetxController {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   var available = false.obs;
//   var isListening = false.obs;

//   final nameController = TextEditingController();
//   final addressController = TextEditingController();
//   final emailController = TextEditingController();

//   Rx<TextEditingController?> selectedField = Rx<TextEditingController?>(null);
//   var selectedLocale = 'en_IN'.obs; // Indian English for better accent detection

//   @override
//   void onInit() {
//     super.onInit();
//     initSpeech();
//   }

//   Future<void> initSpeech() async {
//     available.value = await _speech.initialize(
//       onStatus: (status) {
//         if (status == "done" || status == "notListening") {
//           isListening.value = false;
//         }
//       },
//       onError: (error) {
//         isListening.value = false;
//         Get.snackbar('Error', 'Speech recognition error: ${error.errorMsg}',
//             snackPosition: SnackPosition.BOTTOM);
//       },
//     );
//     if (available.value) {
//       Get.snackbar(
//           'Info',
//           'Speak clearly and say "slash" for "/" (e.g., "six slash A"). For names like "Ijaz," try to pronounce clearly.',
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   Future<void> startListen() async {
//     if (!available.value || selectedField.value == null) {
//       Get.snackbar('Warning', 'Select a text field first',
//           snackPosition: SnackPosition.BOTTOM);
//       return;
//     }

//     isListening.value = true;

//     await _speech.listen(
//       onResult: (result) {
//         if (result.finalResult && result.confidence > 0.7) {
//           String processedText = _processText(result.recognizedWords);
//           _updateSelectedField(processedText);
//         }
//       },
//       listenMode: stt.ListenMode.dictation,
//       pauseFor: const Duration(seconds: 3), // Short pause to avoid noise
//       listenFor: const Duration(minutes: 10),
//       localeId: selectedLocale.value,
//       partialResults: true,
//       cancelOnError: true,
//       sampleRate: 44100,
//     );
//   }

//   void stopListen() {
//     _speech.stop();
//     isListening.value = false;
//   }

//   // Process text for general improvements (address formats, specific names)
//   String _processText(String text) {
//     String processed = text;

//     // 1. Replace "by" with "/" for address formats
//     processed = processed
//         .replaceAll(RegExp(r'\bby\b', caseSensitive: false), '/')
//         .replaceAll(RegExp(r'\s*/\s*'), '/'); // Remove spaces around slash

//     // 2. Standardize common misrecognitions for "Ijaz" (use with caution)
//     // Only uncomment this if 'izaz' and 'ejaj' are highly likely to be misrecognitions of 'Ijaz'
//     // processed = processed
//     //     .replaceAll(RegExp(r'\b(izaz|ejaj)\b', caseSensitive: false), 'Ijaz');

//     // 3. Handle commas
//     processed = processed.replaceAll(RegExp(r'\s*,\s*'), ', ');

//     return processed.trim();
//   }

//   void _updateSelectedField(String text) {
//     final field = selectedField.value;
//     if (field != null && text.trim().isNotEmpty) {
//       // You might want to adjust this filter if very short words are important
//       // if (text.trim().length > 1) {
//         String currentText = field.text;
//         // Add a space only if current text is not empty and new text is not a punctuation mark
//         String separator = (currentText.isNotEmpty && !text.startsWith(RegExp(r'[,./]'))) ? ' ' : '';
//         field.text = '$currentText$separator$text';
//         field.selection = TextSelection.fromPosition(
//           TextPosition(offset: field.text.length),
//         );
//       // }
//     }
//   }

//   // Optional: Allow users to change locale
//   void changeLocale(String newLocale) {
//     selectedLocale.value = newLocale;
//     Get.snackbar('Info', 'Locale changed to $newLocale',
//         snackPosition: SnackPosition.BOTTOM);
//   }
// }
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

  // Locale changed for better recognition
  var selectedLocale = 'en_US'.obs; // Try en_GB if needed

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
        Get.snackbar(
          'Error',
          'Speech recognition error: ${error.errorMsg}',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );

    if (available.value) {
      Get.snackbar(
        'Info',
        'Speak clearly and say "slash" for "/" (e.g., "six slash A").',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> startListen() async {
    if (!available.value || selectedField.value == null) {
      Get.snackbar(
        'Warning',
        'Select a text field first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isListening.value = true;

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult && result.confidence > 0.5) {
          String processedText = _processText(result.recognizedWords);
          _updateSelectedField(processedText);
        }
      },
      listenMode: stt.ListenMode.dictation,
      pauseFor: const Duration(seconds: 6), // Increased pause
      listenFor: const Duration(minutes: 10),
      localeId: selectedLocale.value,
      partialResults: true,
      cancelOnError: true,
      sampleRate: 44100,
    );
  }

  void stopListen() {
    _speech.stop();
    isListening.value = false;
  }

  // Improved text processor with corrections
  String _processText(String text) {
    String processed = text;

    // Numbers
    processed = processed
        .replaceAll(RegExp(r'\bone\b', caseSensitive: false), '1')
        .replaceAll(RegExp(r'\btwo\b', caseSensitive: false), '2')
        .replaceAll(RegExp(r'\bto\b', caseSensitive: false), '2')
        .replaceAll(RegExp(r'\bthree\b', caseSensitive: false), '3')
        .replaceAll(RegExp(r'\bfour\b', caseSensitive: false), '4')
        .replaceAll(RegExp(r'\bfive\b', caseSensitive: false), '5')
        .replaceAll(RegExp(r'\bsix\b', caseSensitive: false), '6')
        .replaceAll(RegExp(r'\bseven\b', caseSensitive: false), '7')
        .replaceAll(RegExp(r'\beight\b', caseSensitive: false), '8')
        .replaceAll(RegExp(r'\bnine\b', caseSensitive: false), '9')
        .replaceAll(RegExp(r'\bzero\b', caseSensitive: false), '0');

    // Slash / by
    processed = processed
        .replaceAll(RegExp(r'\bslash\b', caseSensitive: false), '/')
        .replaceAll(RegExp(r'\bby\b', caseSensitive: false), '/')
        .replaceAll(RegExp(r'\s*/\s*'), '/'); // clean spaces

    // Handle commas
    processed = processed.replaceAll(RegExp(r'\s*,\s*'), ', ');

    // Clean double spaces
    processed = processed.replaceAll(RegExp(r'\s+'), ' ');

    return processed.trim();
  }

  void _updateSelectedField(String text) {
    final field = selectedField.value;
    if (field != null && text.trim().isNotEmpty) {
      String currentText = field.text;
      String separator =
          (currentText.isNotEmpty && !text.startsWith(RegExp(r'[,./]')))
              ? ' '
              : '';
      field.text = '$currentText$separator$text';
      field.selection = TextSelection.fromPosition(
        TextPosition(offset: field.text.length),
      );
    }
  }

  // Optional locale change
  void changeLocale(String newLocale) {
    selectedLocale.value = newLocale;
    Get.snackbar(
      'Info',
      'Locale changed to $newLocale',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
