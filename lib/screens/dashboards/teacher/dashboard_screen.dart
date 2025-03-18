import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  _TeacherDashboardScreenState createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _createAssignment() {
    TextEditingController titleController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController marksController = TextEditingController();
    TextEditingController briefController = TextEditingController();
    TextEditingController pointsController = TextEditingController();
    TextEditingController topicsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Due Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dateController.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
                TextField(
                    controller: marksController,
                    decoration: const InputDecoration(labelText: 'Marks'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: briefController,
                    decoration:
                        const InputDecoration(labelText: 'Question Brief')),
                TextField(
                    controller: pointsController,
                    decoration: const InputDecoration(
                        labelText: 'Points to be Answered')),
                TextField(
                    controller: topicsController,
                    decoration: const InputDecoration(
                        labelText: 'Topics to be Covered')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = _auth.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('User not authenticated!')),
                  );
                  return;
                }

                String userId = user.uid;

                var userDoc =
                    await _firestore.collection('users').doc(userId).get();
                if (!userDoc.exists || userDoc.data()?['role'] != "teacher") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Only teachers can create assignments!')),
                  );
                  return;
                }

                await _firestore.collection('assignments').add({
                  'title': titleController.text,
                  'date': dateController.text,
                  'marks': int.tryParse(marksController.text) ?? 0,
                  'brief': briefController.text,
                  'points': pointsController.text,
                  'topics': topicsController.text,
                  'createdBy': userId, // Store teacher's UID
                  'timestamp': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: _createAssignment,
                child: const Text('Create Assignment'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: _firestore
                    .collection('assignments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No assignments available'));
                  }

                  var assignments = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      var assignment =
                          assignments[index].data() as Map<String, dynamic>;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            assignment['title'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Due: ${assignment['date']} | Marks: ${assignment['marks']}',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
