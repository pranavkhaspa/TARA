import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:convert';
import 'dart:typed_data';

const String geminiApiUrl =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";
const String geminiApiKey =
    "AIzaSyAlQSNUW3oqs-kbguuNThZSfLcvTBZDroM"; // Replace with your actual API key

class UploadAssignmentScreen extends StatefulWidget {
  final String assignmentTitle;
  final String topics;
  final String points;
  final String marks;
  final String createdBy;

  const UploadAssignmentScreen({
    super.key,
    required this.assignmentTitle,
    required this.topics,
    required this.points,
    required this.marks,
    required this.createdBy,
  });

  @override
  _UploadAssignmentScreenState createState() => _UploadAssignmentScreenState();
}

class _UploadAssignmentScreenState extends State<UploadAssignmentScreen> {
  PlatformFile? selectedFile;
  bool isUploading = false;
  bool isSubmissionLocked = false;
  String feedback = "";

  Future<void> pickFile() async {
    if (isSubmissionLocked) return;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  Future<String> extractTextFromPdf(Uint8List bytes) async {
    try {
      PdfDocument document = PdfDocument(inputBytes: bytes);
      String text = '';
      for (int i = 0; i < document.pages.count; i++) {
        text += PdfTextExtractor(document)
            .extractText(startPageIndex: i, endPageIndex: i);
      }
      document.dispose();
      return text;
    } catch (e) {
      return "Error extracting text from PDF: $e";
    }
  }

  Future<void> evaluateFile() async {
    if (selectedFile == null || selectedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid file selected!')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final extractedText = await extractTextFromPdf(selectedFile!.bytes!);
      final trimmedText = extractedText.length > 7000
          ? "${extractedText.substring(0, 7000)}... (text trimmed)"
          : extractedText;

      await _makeApiRequest(trimmedText);
    } catch (e) {
      setState(() {
        feedback = "Error during evaluation: $e";
      });
    } finally {
      setState(() {
        isUploading = false;
        isSubmissionLocked = true;
      });
    }
  }

  Future<void> _makeApiRequest(String documentText) async {
    final prompt = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "Evaluate the student's assignment based on the given topics. Provide a score out of ${widget.marks}, strengths, areas for improvement, and feedback.\n\nAssignment title: ${widget.assignmentTitle}\nKey topics: ${widget.topics}\nMaximum marks: ${widget.marks}\n\nStudent submission:\n$documentText"
            }
          ]
        }
      ]
    };

    try {
      print(jsonEncode(prompt)); // Print the request

      final response = await http
          .post(Uri.parse('$geminiApiUrl?key=$geminiApiKey'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(prompt))
          .timeout(const Duration(seconds: 60)); // Add a timeout

      print(response.statusCode); // Print the status code
      print(response.body); // Print the response body

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String generatedText = data["candidates"][0]["content"]["parts"][0]
                ["text"] ??
            "Evaluation failed";
        setState(() {
          feedback = generatedText;
        });
      } else {
        setState(() {
          feedback =
              "Evaluation failed: Server error ${response.statusCode}, ${response.body}"; // Include response body
        });
      }
    } catch (e) {
      setState(() {
        feedback = "Error making API request: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Assignment',
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                onPressed: isSubmissionLocked ? null : pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Choose File'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed:
                    selectedFile != null && !isUploading && !isSubmissionLocked
                        ? evaluateFile
                        : null,
                icon: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Icon(Icons.upload),
                label: const Text('Evaluate'),
              ),
              const SizedBox(height: 20),
              feedback.isNotEmpty
                  ? Text(feedback, style: GoogleFonts.poppins(fontSize: 16))
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
