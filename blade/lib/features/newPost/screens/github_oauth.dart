import 'package:blade_app/features/newPost/screens/backgroundPost.dart';
import 'package:blade_app/features/newPost/screens/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class GithubAuthentication extends StatefulWidget {
  const GithubAuthentication({super.key});

  @override
  State<GithubAuthentication> createState() => _GithubAuthenticationState();
}

class _GithubAuthenticationState extends State<GithubAuthentication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10), // Similar to YMargin(10)
            Text(
              'Please sign in with your GitHub account to create your idea.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.4),
                height: 1.5,
                fontSize: 12,
              ),
            ),
            const Spacer(), // Space between text and image
            Center(
              child: Image.asset(
                'assets/images/login/github.png', // Make sure this path is correct
                height: 200,
              ),
            ),
            const Spacer(), // Space between image and the button
            Center(
              child: SizedBox(
                width: 350,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24292E), // GitHub black color
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // No rounded corners
                    ),
                  ),
                  icon: const Icon(
                    LineIcons.github,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Sign in with GitHub',
                    style: TextStyle(
                      color: Colors.white, // White text color
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      // Initiating the GitHub sign-in process with public_repo scope
                      UserCredential userCredential = await signInWithGithub();

                      if (userCredential.user != null) {
                        // Extract the OAuthCredential safely from the UserCredential
                        final AuthCredential? githubCredential = userCredential.credential;

                        // Check if the credential contains an access token
                        if (githubCredential != null && githubCredential.accessToken != null) {
                          final String accessToken = githubCredential.accessToken!;

                          // Ensure the widget is still mounted before using context
                          if (mounted) {
                            // Navigate to the Post screen with the valid access token
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BackgroundScreen(accessToken: accessToken),  // Pass the actual access token
                              ),
                            );
                          }
                        } else {
                          _showErrorSnackBar("Failed to retrieve GitHub access token.");
                        }
                      } else {
                        _showErrorSnackBar("User is null after sign-in.");
                      }
                    } catch (e) {
                      _showErrorSnackBar("Error during GitHub sign-in.");
                      print(e); // Print the error for debugging
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<UserCredential> signInWithGithub() async {
    GithubAuthProvider githubAuthProvider = GithubAuthProvider();
    // Add the public_repo scope to the OAuth request
    githubAuthProvider.addScope('public_repo');

    return await FirebaseAuth.instance.signInWithProvider(githubAuthProvider);
  }

  // Display error message as a SnackBar
  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
