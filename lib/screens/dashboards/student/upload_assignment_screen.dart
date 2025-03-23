import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
import 'dart:typed_data';

const String geminiApiKey = "AIzaSyDtIon8Lc-SRbDLnbQW2FkUXUzcYVbQm6o"; // Replace with your Gemini API key

class UploadAssignmentScreen extends StatefulWidget {
  final String assignmentTitle;
  final String topics;
  final String points;
  final String marks;
  final String createdBy; // Added missing property


  const UploadAssignmentScreen({
    Key? key,
    required this.assignmentTitle,
    required this.topics,
    required this.points,
    required this.marks,
    required this.createdBy,
  }) : super(key: key);

  @override
  _UploadAssignmentScreenState createState() => _UploadAssignmentScreenState();
}

class _UploadAssignmentScreenState extends State<UploadAssignmentScreen> {
  PlatformFile? selectedFile;
  bool isUploading = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  Future<void> uploadFile() async {
    if (selectedFile == null || selectedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No valid file selected!')),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('assignments/${selectedFile!.name}');

      final uploadTask = ref.putData(selectedFile!.bytes!);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Evaluate with Gemini
      String feedback = await evaluateWithGemini(selectedFile!.bytes!, downloadUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded: $downloadUrl \n Feedback: $feedback')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<String> evaluateWithGemini(Uint8List fileBytes, String downloadUrl) async {
    final String apiUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent";
    final Map<String, dynamic> requestData = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "Evaluate this assignment titled '${widget.assignmentTitle}' and give marks out of ${widget.marks}. Provide feedback on key points and areas for improvement. Topics: ${widget.topics}, Points: ${widget.points}. The file can be downloaded at: $downloadUrl"
            }
          ]
        }
      ]
    };

    final response = await http.post(
      Uri.parse('$apiUrl?key=$geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No feedback received';
    } else {
      return "Gemini evaluation failed: ${response.body}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Assignment',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedFile == null
                  ? 'No file selected'
                  : 'Selected: ${selectedFile!.name}',
              style: GoogleFonts.poppins(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: Icon(Icons.attach_file),
              label: Text('Choose File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: selectedFile != null && !isUploading ? uploadFile : null,
              icon: isUploading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Icon(Icons.upload),
              label: Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
