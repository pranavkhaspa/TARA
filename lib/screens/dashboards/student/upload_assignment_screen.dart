import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final TextEditingController _directUrlController = TextEditingController();
  InAppWebViewController? webViewController;
  String fileUrl = '';
  String _userEmail = "";
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.readonly'
    ],
  );
  @override
  void initState() {
    super.initState();  
  }
  final String htmlContent = """
    <!DOCTYPE html>
    <html>
    <head>
      <title>Google Picker</title>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <script src="https://accounts.google.com/gsi/client" async defer></script>
      <script src="https://apis.google.com/js/api.js"></script>
      <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 20px; background-color: #f4f4f4; }
        button { 
          background-color: #4285F4; color: white; border: none; 
          padding: 10px 20px; font-size: 16px; cursor: pointer; 
          border-radius: 5px; margin-top: 10px;
        }
        button:hover { background-color: #357ae8; }
        input { width: 80%; padding: 8px; margin-top: 10px; }
      </style>
    </head>
    <body>
    <h2>Select File from Google Drive</h2>
    <button onclick="signInWithGoogle()">Sign in with Google</button>
    <p id="userEmail"></p>
    <button onclick="openGooglePicker()">Choose File</button>
    <input type="text" id="fileLink" placeholder="File URL" readonly/>
    <script>
    let accessToken = "";
    function signInWithGoogle() {
      google.accounts.oauth2.initTokenClient({
          client_id: "YOUR_CLIENT_ID",
          scope: "https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.readonly",
          callback: (tokenResponse) => {
              accessToken = tokenResponse.access_token;
              fetchUserInfo();
          }
      }).requestAccessToken();
    }
    function fetchUserInfo() {
      fetch("https://www.googleapis.com/oauth2/v1/userinfo?alt=json", {
          headers: { Authorization: `Bearer \${accessToken}` }
      })
      .then(response => response.json())
      .then(data => {
          document.getElementById("userEmail").innerText = `Signed in as: \${data.email}`;
      });  
    }
    function openGooglePicker() {
        gapi.load("picker", function() {
            let picker = new google.picker.PickerBuilder()
                .addView(google.picker.ViewId.DOCS)
                .setOAuthToken(accessToken)
                .setDeveloperKey("YOUR_API_KEY")
                .setCallback(pickerCallback)
                .build();
            picker.setVisible(true);
        });
    }
    function pickerCallback(data) {
      if (data.action === google.picker.Action.PICKED) {
          let fileId = data.docs[0].id;
          let fileUrl = `https://drive.google.com/uc?export=download&id=\${fileId}`;
          document.getElementById("fileLink").value = fileUrl;
          window.flutter_inappwebview.callHandler('directUrlHandler', fileUrl);
      }
    }    
</script>
</body>
</html>
    """;

  Future<void> _submitLink(String fileUrl) async {
    if (fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please convert a link to submit.")),
      );
      return;
    }
    try {
      GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      await FirebaseFirestore.instance.collection('submissions').add({
        'assignmentId': widget.assignmentId,
        'userId': user!.id,
        'fileUrl': fileUrl,
        'submittedAt': Timestamp.now(),
        'createdBy': widget.createdBy,
      });
    
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assignment submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission failed : $e")),
      );
    }
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Scaffold(
                                appBar: AppBar(
                                    title: const Text('Google Picker')),
                                body: InAppWebView(
                                  initialData: InAppWebViewInitialData(
                                      data: htmlContent),
                                  initialOptions: InAppWebViewGroupOptions(
                                    crossPlatform: InAppWebViewOptions(
                                      supportZoom: false,
                                    ),
                                  ),
                                  onWebViewCreated:
                                      (InAppWebViewController controller) {
                                    webViewController = controller;
                                    webViewController!
                                        .addJavaScriptHandler(
                                            handlerName: 'directUrlHandler',
                                            callback: (args) {
                                               setState(() {
                                                fileUrl =
                                                    args[0].toString();
                                                _directUrlController.text =
                                                    fileUrl;
                                              });
                                            });
                                  },
                                ),
                              )));
                },
                child: const Text("Open Google Picker")),
            TextField(
              controller: _directUrlController,
              decoration: const InputDecoration(
                  labelText: "Direct Url will be here"),
              enabled: false,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {
                   _submitLink(fileUrl);
                 }, child: const Text("Submit")),
          ],
        )
    )
    );
  }
}
