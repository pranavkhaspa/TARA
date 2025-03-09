import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class UploadAssignmentScreen extends StatefulWidget {
  const UploadAssignmentScreen({super.key});

  @override
  _UploadAssignmentScreenState createState() => _UploadAssignmentScreenState();
}

class _UploadAssignmentScreenState extends State<UploadAssignmentScreen> {
  String? fileName;
  File? file;
  bool isUploading = false;

  // Function to pick a file (PDF)
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  // Function to upload the file to Firebase
  Future<void> uploadFile() async {
    if (file == null) return;
    setState(() {
      isUploading = true;
    });

    try {
      String filePath =
          'assignments/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save file metadata to Firestore
      await FirebaseFirestore.instance.collection('student_assignments').add({
        'fileName': fileName,
        'fileUrl': downloadUrl,
        'uploadedAt': Timestamp.now(),
      });

      setState(() {
        file = null;
        fileName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload Successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload Failed: $e')),
      );
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Assignment')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            fileName != null
                ? Text('Selected File: $fileName',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                : Text('No file selected', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: Icon(Icons.upload_file),
              label: Text('Pick a PDF'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isUploading ? null : uploadFile,
              icon: Icon(Icons.send),
              label: isUploading
                  ? CircularProgressIndicator()
                  : Text('Submit Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}
