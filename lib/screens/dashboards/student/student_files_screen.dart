import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upload_assignment_screen.dart';

class StudentFilesScreen extends StatelessWidget {
  final String studentId;

  const StudentFilesScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
            var assignmentData = assignment.data() as Map<String, dynamic>?;

            if (assignmentData == null) return const SizedBox();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('assignments')
                  .doc(assignment.id)
                  .collection('submissions')
                  .doc(studentId)
                  .get(),
              builder: (context, submissionSnapshot) {
                String submissionStatus = "Not Submitted";
                String marks = "N/A";
                String feedback = "No feedback";

                if (submissionSnapshot.connectionState == ConnectionState.done &&
                    submissionSnapshot.data != null &&
                    submissionSnapshot.data!.exists) {
                  var submissionData = submissionSnapshot.data!.data() as Map<String, dynamic>?;

                  if (submissionData != null) {
                    submissionStatus = "Submitted";
                    marks = submissionData['marks']?.toString() ?? "Not Graded";
                    feedback = submissionData['feedback'] ?? "No feedback yet";
                  }
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
                      assignmentData['title'] ?? 'No Title',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Due Date: ${assignmentData['date'] ?? 'N/A'}",
                            style: GoogleFonts.poppins(fontSize: 14)),
                        Text("Status: $submissionStatus",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: submissionStatus == "Submitted" ? Colors.green : Colors.red,
                            )),
                        Text("Marks: $marks",
                            style: GoogleFonts.poppins(fontSize: 14)),
                        Text("Feedback: $feedback",
                            style: GoogleFonts.poppins(fontSize: 14)),
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
                              assignmentId: assignment.id,
                              assignmentTitle: assignmentData['title'] ?? 'No Title',
                              createdBy: assignmentData['createdBy'] ?? 'Unknown',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        submissionStatus == "Submitted" ? "Resubmit" : "Upload",
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
        );
      },
    );
  }
}
