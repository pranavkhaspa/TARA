  import 'package:flutter/material.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:firebase_storage/firebase_storage.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'dart:io';

  class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('Student Dashboard')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Due Assignments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                title: Text('Assignment 1'),
                subtitle: Text('Due: March 10, 2025'),
                trailing: Icon(Icons.arrow_forward),
              ),
              SizedBox(height: 16),
              Text('Submitted Assignments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                title: Text('Assignment 2'),
                subtitle: Text('Grade: A, Feedback: Good work!'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UploadAssignmentScreen()));
                },
                child: Text('Upload Assignment'),
              )
            ],
          ),
        ),
      );
    }
  }

  class UploadAssignmentScreen extends StatefulWidget {
  const UploadAssignmentScreen({super.key});

    @override
    _UploadAssignmentScreenState createState() => _UploadAssignmentScreenState();
  }

  class _UploadAssignmentScreenState extends State<UploadAssignmentScreen> {
    String? fileName;
    File? file;
    bool isUploading = false;

    Future<void> pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        setState(() {
          file = File(result.files.single.path!);
          fileName = result.files.single.name;
        });
      }
    }

    Future<void> uploadFile() async {
      if (file == null) return;
      setState(() { isUploading = true; });

      try {
        String filePath = 'assignments/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        Reference ref = FirebaseStorage.instance.ref().child(filePath);
        UploadTask uploadTask = ref.putFile(file!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('student_assignments').add({
          'fileName': fileName,
          'fileUrl': downloadUrl,
          'uploadedAt': Timestamp.now(),
        });

        setState(() { file = null; fileName = null; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Successful!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Failed: $e')));
      }

      setState(() { isUploading = false; });
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
              fileName != null ? Text('Selected File: $fileName', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)) : Text('No file selected', style: TextStyle(fontSize: 16)),
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
                label: isUploading ? CircularProgressIndicator() : Text('Submit Assignment'),
              )
            ],
          ),
        ),
      );
    }
  }

  class StudentFilesScreen extends StatelessWidget {
  const StudentFilesScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('Student Files')),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('student_assignments').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var files = snapshot.data!.docs;
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                var file = files[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(file['fileName'], style: TextStyle(fontSize: 16)),
                    trailing: IconButton(
                      icon: Icon(Icons.download, color: Colors.blue),
                      onPressed: () {}, // Implement download functionality
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }
