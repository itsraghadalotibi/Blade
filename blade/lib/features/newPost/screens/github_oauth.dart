import 'dart:convert';
import 'package:blade_app/features/newPost/screens/backgroundPost.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GithubAuthentication extends StatefulWidget {
  const GithubAuthentication({super.key});

  @override
  State<GithubAuthentication> createState() => _GithubAuthenticationState();
}

class _GithubAuthenticationState extends State<GithubAuthentication> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Authentication'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    FontAwesomeIcons.githubAlt,
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 44,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Connect with GitHub',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Connect with GitHub to create a team repo and start collaborating!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.4),
                height: 1.5,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Center(
              child: Image.asset(
                'assets/images/login/github.png',
                height: 200,
              ),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 350,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24292E),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  icon: const Icon(
                    LineIcons.github,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Connect with GitHub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final String accessToken = await getGithubAccessToken();

                      if (accessToken.isNotEmpty) {
                        print("GitHub token: $accessToken");

                        // Store the token securely
                        await secureStorage.write(
                          key: 'github_access_token', 
                          value: accessToken
                        );

                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BackgroundScreen(
                                accessToken: accessToken,
                              ),
                            ),
                          );
                        }
                      } else {
                        _showErrorSnackBar("Failed to retrieve GitHub access token.");
                      }
                    } catch (e) {
                      _showErrorSnackBar("Error during GitHub sign-in.");
                      print(e);
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

  Future<String> getGithubAccessToken() async {
    final String clientId = 'Ov23liG9JalaLxAeKYln';
    final String clientSecret = 'b0d93d6535f1eb37b7800ce29bdf3c00b20c627b';
    final String redirectUri = 'com.example.blade://callback';

    // Step 1: Open the GitHub authorization page.
    // final result = await FlutterWebAuth.authenticate(
    //   url: 'https://github.com/login/oauth/authorize?client_id=$clientId&scope=public_repo&redirect_uri=$redirectUri',
    //   callbackUrlScheme: 'com.example.blade',
    // );

    // Step 2: Extract the code from the result.
    // final code = Uri.parse(result).queryParameters['code'];

    // if (code == null) {
    //   throw Exception('Failed to obtain authorization code.');
    // }

    // Step 3: Exchange the code for an access token.
    final response = await http.post(
      Uri.parse('https://github.com/login/oauth/access_token'),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        // 'code': code,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return body['access_token'] ?? '';
    } else {
      print('Failed to retrieve access token: ${response.body}');
      return '';
    }
  }

  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
