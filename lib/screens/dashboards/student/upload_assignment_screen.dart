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
const String modelId =
    "google/gemma-3-27b-it"; // Using the requested Gemma 3 model
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
  String extractedText = "";
  String errorDetails = "";
  int retryCount = 0;
  final int maxRetries = 3;

  // Get the next API key in rotation
  String getNextApiKey() {
    final key = huggingFaceApiKeys[currentKeyIndex];
    currentKeyIndex = (currentKeyIndex + 1) % huggingFaceApiKeys.length;
    return key;
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Ensures file bytes are available
    );
    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  Future<String> extractTextFromPdf(Uint8List bytes) async {
    // Load the PDF document
    PdfDocument document = PdfDocument(inputBytes: bytes);
    String text = '';

    // Extract text from all pages
    for (int i = 0; i < document.pages.count; i++) {
      text += PdfTextExtractor(document)
          .extractText(startPageIndex: i, endPageIndex: i);
    }

    // Dispose the document
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
      // Extract text from the PDF
      final extractedText = await extractTextFromPdf(selectedFile!.bytes!);

      // Trim text if it's too long (models often have token limits)
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
    // Create prompt for evaluation
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
      // Get the next API key in rotation
      final apiKey = getNextApiKey();

      // API Request to Hugging Face Inference API
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
        final responseBody = response.body;

        // Try to parse as JSON
        try {
          final data = jsonDecode(responseBody);
          String generatedText = "";

          if (data is List && data.isNotEmpty) {
            if (data[0] is Map && data[0].containsKey('generated_text')) {
              generatedText = data[0]['generated_text'];
            } else {
              generatedText = data.toString();
            }
          } else if (data is Map && data.containsKey('generated_text')) {
            generatedText = data['generated_text'];
          } else {
            generatedText = data.toString();
          }

          setState(() {
            feedback = generatedText;
          });
        } catch (e) {
          // If JSON parsing fails, use the raw response
          setState(() {
            feedback = responseBody;
          });
        }
      } else if (response.statusCode == 503) {
        // Model is loading
        if (retryCount < maxRetries) {
          setState(() {
            feedback =
                "The model is loading. Retry attempt ${retryCount + 1}/${maxRetries}...";
          });

          // Wait before retrying
          await Future.delayed(Duration(seconds: 10));

          setState(() {
            retryCount++;
          });

          // Try again with the next API key
          await _makeApiRequest(documentText);
        } else {
          setState(() {
            feedback = "The model is still loading after multiple attempts.";
            errorDetails =
                "Status: ${response.statusCode}\nBody: ${response.body}";
          });
        }
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        if (retryCount < maxRetries) {
          setState(() {
            feedback =
                "Rate limit exceeded. Trying with a different API key...";
          });

          // Wait a moment before retrying
          await Future.delayed(Duration(seconds: 2));

          setState(() {
            retryCount++;
          });

          // Try again with the next API key
          await _makeApiRequest(documentText);
        } else {
          setState(() {
            feedback = "Rate limit exceeded for all API keys.";
            errorDetails =
                "Status: ${response.statusCode}\nBody: ${response.body}";
          });
        }
      } else {
        setState(() {
          feedback = "Evaluation failed";
          errorDetails =
              "Status: ${response.statusCode}\nBody: ${response.body}";
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
                onPressed:
                    selectedFile != null && !isUploading ? evaluateFile : null,
                icon: isUploading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Icon(Icons.upload),
                label: Text('Evaluate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              feedback.isNotEmpty
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Evaluation Feedback:",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            feedback,
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          if (errorDetails.isNotEmpty) ...[
                            SizedBox(height: 16),
                            ExpansionTile(
                              title: Text(
                                "Error Details",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    errorDetails,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
