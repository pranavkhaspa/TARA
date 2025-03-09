# TARA:Teaching Assistant for Review and Assesment

## Project Overview

This project aims to create an AI Teaching Assistant designed to significantly reduce the burden on teachers by automating the assignment evaluation process. The system enables teachers to effortlessly create assignments, while students can submit their handwritten assignments in the form of images. Utilizing the power of Google Cloud Vision API, the project employs Optical Character Recognition (OCR) for evaluating these assignments, providing an efficient auto-grading system. To ensure academic integrity, the project also includes duplicate detection capabilities. Furthermore, the system automatically generates Google Sheets reports, streamlining the administrative tasks for teachers.

---



## 1️⃣ App Overview & Objectives

The AI Teaching Assistant is designed to **reduce the burden on teachers** by automating assignment evaluation. Teachers create assignments with an optional answer key, and students submit handwritten assignments as images. The system uses **Google Cloud Vision API** for OCR-based evaluation and provides auto-grading with teacher override functionality. The app also ensures **duplicate submission detection** and generates **Google Sheets reports** for teachers.

---


## 2️⃣ Target Audience

- **Teachers/Lecturers** → Assign work, review AI grading, finalize marks.
- **Students** → Submit handwritten assignments, view marks & feedback.
- **Educational Institutions** → Reduce grading workload, improve efficiency.

---

## 3️⃣ Core Features & Functionality

### 👩‍🏫 Teacher Features:

✅ **Create Assignments** → Set deadlines, allow/disallow late submissions.
✅ **Generate Submission Link** → Students use this to upload assignments.
✅ **Upload Answer Key** (optional) → Helps AI grade more accurately.
✅ **View All Submissions** → Detect duplicate submissions.
✅ **Review & Override AI Grades** → Adjust marks before finalizing.
✅ **Download Google Sheets Report** → Contains marks & submission details.
✅ **Receive Notifications** → When all students submit or after the deadline.

### 👨‍🎓 Student Features:

✅ **Google Sign-In** → Secure authentication.
✅ **Upload Handwritten Assignments** → Image-based submission.
✅ **View Marks & AI Feedback** → Understand grading decisions.
✅ **Receive Email Notification** → When grading is complete.
✅ **Late Submission Marking** → If allowed, flagged as "Late Submission."

---

## 4️⃣ High-Level Tech Stack Recommendations

- **Frontend:** Flutter (Mobile) or Firebase Hosting + Web App
- **Backend:** Firebase Functions (Serverless, Scalable)
- **Database:** Firestore (Real-time, Flexible)
- **Storage:** Google Cloud Storage (For images)
- **OCR & AI:** Google Cloud Vision API (Text extraction & auto-grading)
- **Authentication:** Firebase Authentication (Google Sign-In)
- **Notifications:** Firebase Cloud Messaging (FCM) + Email (via Firebase Functions)
- **Reports:** Google Sheets API (Automated Marksheet Generation)

---

## 5️⃣ Conceptual Data Model

### 🔹 **Assignments Collection**

- Assignment ID
- Teacher ID
- Deadline & Late Submission Policy
- Answer Key (Optional)
- Submission Link

### 🔹 **Submissions Collection**

- Submission ID
- Student ID
- Assignment ID
- Submission Image URL
- AI Extracted Text
- AI Score & Feedback
- Late Submission Status
- Teacher Adjusted Marks (if overridden)

### 🔹 **Users Collection**

- User ID
- Role (Student/Teacher)
- Name, Email (Google Sign-In)

---

## 6️⃣ User Interface (UI) Design Principles

🎨 **Simple & Clean:** Minimal clutter for easy navigation.
📱 **Mobile-First Approach:** Works seamlessly on both web & mobile.
🔍 **Focus on Usability:** Easy-to-use dashboards for teachers & students.
📊 **Clear Visuals:** Graphs & tables for student performance tracking.

---

## 7️⃣ Security Considerations (For Future Refinement)

- 🔐 **Secure Assignment Storage:** Only students & teachers can access submissions.
- 🚫 **Duplicate Detection Privacy:** Flagged but not exposed to other students.
- ⚡ **Rate Limiting & Spam Protection:** Prevent misuse of the system.

---

## 8️⃣ Development Phases & Milestones

### 🏗️ **Phase 1: MVP (Core Features)**

✅ Google Sign-In for Students & Teachers
✅ Assignment Creation & Submission Link Generation
✅ Student Handwritten Submission (Image Upload)
✅ OCR-Based Auto-Grading with Answer Key Matching
✅ Marks & AI Feedback Display for Students
✅ Google Sheets Report Generation for Teachers

### 🚀 **Phase 2: Enhancements & Scaling**

🔄 Late Submission Management & Teacher Deadline Edits
🔎 Smarter Duplicate Detection (Handwriting Analysis)
📩 Automated Email & Push Notifications
📊 Analytics Dashboard for Performance Tracking

---

## 9️⃣ Potential Challenges & Solutions

| Challenge | Solution |
| --- | --- |
| OCR Misreading Handwriting | Pre-processing images for better accuracy |
| False Positives in Duplicate Detection | Implement confidence thresholds |
| Teacher Overrides AI Scoring Often | Improve grading model iteratively |
| Scalability for Large Student Groups | Optimize Firestore queries & storage |

---

## 🔟 Future Expansion Possibilities

- ✅ **Multi-Classroom Support** → Manage multiple classes per teacher.
- 📚 **AI-Powered Insights** → Personalized feedback beyond simple keyword matching.
- 🎓 **Plagiarism Detection** → AI-based content similarity checks.
- 🔗 **LMS Integration** → Sync with Google Classroom & other platforms.

---

## 🎯 Final Thoughts

This **MVP will be fully functional** while keeping things simple and scalable. Google’s ecosystem provides a **strong foundation**, and future improvements can be **iteratively added** as needed. Let’s build this! 🚀

# Project File structure

lib/
├── main.dart  # Entry point of the app
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   ├── teacher/
│   │   ├── dashboard_screen.dart
│   │   ├── create_assignment_screen.dart
│   │   ├── submissions_screen.dart
│   │   ├── student_list_screen.dart
│   ├── student/
│   │   ├── dashboard_screen.dart
│   │   ├── upload_submission_screen.dart
│   │   ├── grades_feedback_screen.dart
│   ├── settings_screen.dart
├── widgets/
│   ├── custom_button.dart
│   ├── assignment_card.dart
│   ├── submission_card.dart
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── grading_service.dart
│   ├── notification_service.dart
├── models/
│   ├── user_model.dart
│   ├── assignment_model.dart
│   ├── submission_model.dart
└── utils/
    ├── constants.dart
    └── helpers.dart


A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
