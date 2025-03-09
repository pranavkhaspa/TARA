import 'package:flutter/material.dart';
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
        title: const Text('Document List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No documents found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final document = snapshot.data![index];
                return ListTile(
                  title: Text(document['name']),
                );
              },
            );
          }
        },
      ),
    );
  }
}