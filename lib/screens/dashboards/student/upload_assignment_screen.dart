import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:typed_data';

// API key rotation setup
const List<String> huggingFaceApiKeys = [
  "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",
  "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",
  "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"
];
const String modelId = "google/gemma-3-27b-it";
int currentKeyIndex = 0;

class UploadAssignmentScreen extends StatefulWidget {
  final String assignmentTitle;
  final String topics;
  final String points;
  final String marks;
  final String createdBy;

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
  String feedback = "";
  String errorDetails = "";
  int retryCount = 0;
  final int maxRetries = 3;

  String getNextApiKey() {
    final key = huggingFaceApiKeys[currentKeyIndex];
    currentKeyIndex = (currentKeyIndex + 1) % huggingFaceApiKeys.length;
    return key;
  }

  Future<void> pickFile() async {
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
    PdfDocument document = PdfDocument(inputBytes: bytes);
    String text = '';
    for (int i = 0; i < document.pages.count; i++) {
      text += PdfTextExtractor(document)
          .extractText(startPageIndex: i, endPageIndex: i);
    }
    document.dispose();
    return text;
  }

  Future<void> evaluateFile() async {
    if (selectedFile == null || selectedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No valid file selected!')),
      );
      return;
    }

    setState(() {
      isUploading = true;
      errorDetails = "";
      retryCount = 0;
    });

    try {
      final extractedText = await extractTextFromPdf(selectedFile!.bytes!);
      final trimmedText = extractedText.length > 7000
          ? "${extractedText.substring(0, 7000)}... (text trimmed due to length)"
          : extractedText;

      await _makeApiRequest(trimmedText);
    } catch (e) {
      setState(() {
        feedback = "Error occurred during evaluation";
        errorDetails = e.toString();
      });
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> _makeApiRequest(String documentText) async {
    final apiKey = getNextApiKey();
    final prompt = """
    <system>
    You are an expert teacher evaluating student assignments. You provide clear, constructive feedback and fair scoring.
    </system>
    
    <user>
    Please evaluate this assignment submission:
    
    Assignment title: ${widget.assignmentTitle}
    Key topics: ${widget.topics}
    Maximum marks: ${widget.marks}
    
    Student submission:
    $documentText
    
    Provide:
    1. A score out of ${widget.marks}
    2. Detailed feedback on strengths
    3. Areas for improvement
    4. How well the assignment covers the required topics
    </user>
    """;

    try {
      final response = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/$modelId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': 1024,
            'temperature': 0.2,
            'top_p': 0.9,
            'return_full_text': false
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String generatedText = data is List && data.isNotEmpty && data[0] is Map
            ? data[0]['generated_text'] ?? data.toString()
            : data.toString();
        setState(() {
          feedback = generatedText;
        });
      } else {
        setState(() {
          feedback = "Evaluation failed";
          errorDetails = "Status: ${response.statusCode}\nBody: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        feedback = "Error making API request";
        errorDetails = e.toString();
      });
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
                onPressed: pickFile,
                icon: Icon(Icons.attach_file),
                label: Text('Choose File'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: selectedFile != null && !isUploading ? evaluateFile : null,
                icon: isUploading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Icon(Icons.upload),
                label: Text('Evaluate'),
              ),
              const SizedBox(height: 20),
              feedback.isNotEmpty ? Text(feedback, style: GoogleFonts.poppins(fontSize: 16)) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
