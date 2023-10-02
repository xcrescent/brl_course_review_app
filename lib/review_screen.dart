import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  double _rating = 0.0;
  String _selectedSection = 'Section 1';
  String _selectedVideo = 'Video 1';
  @override
  initState() {
    super.initState();
    user = _auth.currentUser;
  }

  List<String> sections = ['Section 1', 'Section 2', 'Section 3'];
  List<String> videos = ['Video 1', 'Video 2', 'Video 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Review'),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20) +
              const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Select the section and video',
                style: TextStyle(
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.roboto().fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedSection,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSection = newValue!;
                  });
                },
                items: sections.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: GoogleFonts.roboto().fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedVideo,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVideo = newValue!;
                  });
                },
                items: videos.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: GoogleFonts.roboto().fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              const Text(
                'Rate this video',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _rating,
                onChanged: (newValue) {
                  setState(() {
                    _rating = newValue;
                  });
                },
                min: 0,
                max: 5,
                divisions: 5,
                label: 'Rating: $_rating',
              ),
              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  labelText: 'Write your review...',
                  contentPadding: EdgeInsets.only(top: 1),
                ),
                maxLines: 4,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                autofocus: true,
                cursorHeight: 20,
                cursorWidth: 4,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: GoogleFonts.roboto().fontFamily,
                ),
                cursorRadius: const Radius.circular(20),
                keyboardAppearance: Brightness.dark,
                // contentInsertionConfiguration: ContentInsertionConfiguration(
                //   onContentInserted: (KeyboardInsertedContent value) {
                //     print(value);
                //   },
                // ),
                enableSuggestions: true,
                maxLength: 500,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: saveReview,
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveReview() async {
    final double rating = _rating;
    final String review = _reviewController.text;
    if (rating == 0.0 || review.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Please enter a valid rating and review.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          });
      return;
    }
    // Assuming you have a reference to your video/document and section/collection
    // Replace 'videos' and 'reviews' with your actual Firestore collection names.

    await FirebaseFirestore.instance
        .collection('sections')
        .doc(_selectedSection)
        .collection(_selectedVideo)
        .doc(user!.email)
        .set({
      // 'email': user!.email,
      'rating': rating,
      'review': review,
      'timestamp': FieldValue.serverTimestamp(),
    }).then(
      (value) => showPopup(context),
    );

    _reviewController.clear();
    setState(() {
      _rating = 0.0;
    });
  }

  void showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Review Saved!'),
          content: const Text(
              'Your review is saved successfully. You can change your review anytime by resubmitting.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
