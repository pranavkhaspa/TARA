import 'dart:io' show File;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class UploadAssignmentScreen extends StatefulWidget {
  final String assignmentId;
  final String assignmentTitle;
  final String createdBy;

  const UploadAssignmentScreen({
    Key? key,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.createdBy,
  }) : super(key: key);

  @override
  _UploadAssignmentScreenState createState() => _UploadAssignmentScreenState();
}

class _UploadAssignmentScreenState extends State<UploadAssignmentScreen> {
  String? fileName;
  File? file;
  bool isUploading = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        fileName = result.files.single.name;
        file = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected")),
      );
    }
  }

  Future<void> uploadFile() async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file to upload")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      // Create a PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Assignment Submission", style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 20),
                pw.Text("Title: ${widget.assignmentTitle}", style: pw.TextStyle(fontSize: 18)),
                pw.Text("Created By: ${widget.createdBy}"),
                pw.Text("Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}"),
              ],
            );
          },
        ),
      );

      // Save PDF
      final output = await getTemporaryDirectory();
      final pdfFile = File("${output.path}/submission.pdf");
      await pdfFile.writeAsBytes(await pdf.save());

      // Upload PDF to Firebase Storage
      String pdfPath = 'assignments/${widget.assignmentId}/submission.pdf';
      Reference storageRef = FirebaseStorage.instance.ref().child(pdfPath);
      await storageRef.putFile(pdfFile);
      String fileUrl = await storageRef.getDownloadURL();

      // Save submission details in Firestore
      await FirebaseFirestore.instance.collection('submissions').add({
        'assignmentId': widget.assignmentId,
        'fileName': 'submission.pdf',
        'fileUrl': fileUrl,
        'submittedAt': Timestamp.now(),
        'createdBy': widget.createdBy,
        'title': widget.assignmentTitle,
      });

      sendToAI(fileUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assignment submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }

    setState(() => isUploading = false);
  }

  void sendToAI(String fileUrl) {
    debugPrint("Sending file to AI for grading: $fileUrl");
    // TODO: Integrate AI grading API here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload ${widget.assignmentTitle}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Your Assignment File",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: pickFile,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Center(
                  child: fileName == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload_file, size: 50, color: Colors.blueAccent),
                            const SizedBox(height: 8),
                            Text("Tap to upload", style: GoogleFonts.poppins(fontSize: 16)),
                          ],
                        )
                      : Text(fileName!,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: (fileName != null && !isUploading) ? uploadFile : null,
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Submit",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
