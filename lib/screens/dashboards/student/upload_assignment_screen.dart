import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:convert';
import 'dart:typed_data';

const String geminiApiUrl =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent";
const String geminiApiKey = "AIzaSyAYyoaZYEISOzz-5aJaXym2xVFZ7q9Ie4Q";

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
                  "You are an expert teacher evaluating student assignments. Provide a score out of ${widget.marks}, detailed feedback, strengths, areas for improvement, and how well the assignment covers the required topics.\n\nAssignment title: ${widget.assignmentTitle}\nKey topics: ${widget.topics}\nMaximum marks: ${widget.marks}\n\nStudent submission:\n$documentText"
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse('$geminiApiUrl?key=$geminiApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(prompt),
      );

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
          feedback = "Evaluation failed";
        });
      }
    } catch (e) {
      setState(() {
        feedback = "Error making API request";
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
                icon: Icon(Icons.attach_file),
                label: Text('Choose File'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed:
                    selectedFile != null && !isUploading && !isSubmissionLocked
                        ? evaluateFile
                        : null,
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
