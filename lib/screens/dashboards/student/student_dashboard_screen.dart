import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upload_assignment_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('assignments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No assignments available"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var assignment = snapshot.data!.docs[index];
              var assignmentRef = assignment.reference;
              var assignmentData = assignment.data() as Map<String, dynamic>?;

              // Ensure 'grade' field exists in Firestore document
              if (assignmentData != null && !assignmentData.containsKey('grade')) {
                assignmentRef.set({'grade': 'Not Assigned'}, SetOptions(merge: true));
              }

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    assignmentData?['title'] ?? 'No Title',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Due Date: ${assignmentData?['date'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Text(
                        "Marks: ${assignmentData?['marks']?.toString() ?? 'N/A'}",
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Text(
                        "Grade: ${assignmentData?['grade'] ?? 'Not Assigned'}",
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadAssignmentScreen(
                            assignmentTitle: assignmentData?['title'] ?? 'No Title',
                            createdBy: assignmentData?.containsKey('createdBy') == true
                                ? assignmentData!['createdBy'].toString()
                                : 'Unknown',
                            topics: assignmentData?['topics'] ?? 'Default topics',
                            points: (assignmentData?['points'] as String?) ?? 'Default points',
                            marks: (assignmentData?['marks']?.toString() ?? '0'),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Upload",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
