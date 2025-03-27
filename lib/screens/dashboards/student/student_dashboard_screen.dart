import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upload_assignment_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  final String studentId;

  const StudentDashboardScreen({super.key, required this.studentId});

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
        builder: (context, assignmentSnapshot) {
          if (assignmentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!assignmentSnapshot.hasData || assignmentSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No assignments available"));
          }

          return ListView.builder(
            itemCount: assignmentSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var assignment = assignmentSnapshot.data!.docs[index];
              var assignmentData = assignment.data() as Map<String, dynamic>?;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('submissions')
                    .where('studentId', isEqualTo: studentId)
                    .where('title', isEqualTo: assignmentData?['title'])
                    .snapshots(),
                builder: (context, submissionSnapshot) {
                  if (!submissionSnapshot.hasData || submissionSnapshot.data!.docs.isEmpty) {
                    // No submission found
                    return _buildAssignmentCard(
                      context,
                      assignmentData,
                      hasSubmitted: false,
                      hasMarks: false,
                    );
                  }

                  var submission = submissionSnapshot.data!.docs.first;
                  var submissionData = submission.data() as Map<String, dynamic>?;

                  bool hasMarks = submissionData?['marks'] != null &&
                      submissionData?['marks'] != 'N/A';

                  return _buildAssignmentCard(
                    context,
                    assignmentData,
                    hasSubmitted: true,
                    hasMarks: hasMarks,
                    marks: submissionData?['marks'],
                    feedback: submissionData?['feedback'],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Map<String, dynamic>? assignmentData,
      {required bool hasSubmitted, required bool hasMarks, String? marks, String? feedback}) {
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
            Text("Due Date: ${assignmentData?['date'] ?? 'N/A'}",
                style: GoogleFonts.poppins(fontSize: 14)),
            hasMarks
                ? Text("Marks: $marks", style: GoogleFonts.poppins(fontSize: 14))
                : const SizedBox(),
            hasMarks
                ? Text("Feedback: $feedback", style: GoogleFonts.poppins(fontSize: 14))
                : const SizedBox(),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: hasMarks
                ? Colors.green
                : hasSubmitted
                    ? Colors.orange
                    : Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (hasMarks) {
              // Show marks and feedback
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Assignment Feedback"),
                  content: Text("Marks: $marks\nFeedback: $feedback"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    ),
                  ],
                ),
              );
            } else if (!hasSubmitted) {
              // Navigate to Upload Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadAssignmentScreen(
                    assignmentTitle: assignmentData?['title'] ?? 'No Title',
                    createdBy: assignmentData?['createdBy'] ?? 'Unknown',
                    topics: assignmentData?['topics'] ?? 'No Topics',
                    points: assignmentData?['points'] ?? 'No Points',
                    marks: assignmentData?['marks']?.toString() ?? 'No Marks',
                  ),
                ),
              );
            }
          },
          child: Text(
            hasMarks ? "Check Marks" : hasSubmitted ? "Submitted" : "Upload",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
