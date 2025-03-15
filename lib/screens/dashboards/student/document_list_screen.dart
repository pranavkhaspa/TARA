import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/auth_service.dart';

class DocumentListScreen extends StatefulWidget {
  final String userId;

  const DocumentListScreen({super.key, required this.userId});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  late Future<List<Map<String, dynamic>>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _documentsFuture = AuthService().getUserDocuments(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Document List',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No documents found',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final document = snapshot.data![index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                    title: Text(
                      document['name'],
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: document.containsKey('date')
                        ? Text(
                            'Uploaded: ${document['date']}',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                          )
                        : null,
                    trailing: IconButton(
                      icon: Icon(Icons.download, color: Colors.blueAccent),
                      onPressed: () {
                        // Handle download action
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}