import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_text/voice_controller.dart';

class SpeechToTextScreen extends StatelessWidget {
  SpeechToTextScreen({super.key});

  final SpeechController controller = Get.put(SpeechController());

  Widget _buildTextField(
      String label, TextEditingController textController) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(labelText: label),
      onTap: () {
        controller.selectedField.value = textController; // যেটা tap হবে সেটা সিলেক্টেড
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Speech To Text")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Name", controller.nameController),
            const SizedBox(height: 10),
            _buildTextField("Address", controller.addressController),
            const SizedBox(height: 10),
            _buildTextField("Email", controller.emailController),
            const Spacer(),

            // ✅ শুধু ১টা Mic button
            Obx(() => FloatingActionButton(
                  onPressed: () {
                    if (controller.isListening.value) {
                      controller.stopListen();
                    } else {
                      controller.startListen();
                    }
                  },
                  child: Icon(controller.isListening.value
                      ? Icons.mic
                      : Icons.mic_none),
                )),
          ],
        ),
      ),
    );
  }
}
