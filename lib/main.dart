import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> sendEmail({
    required String name,
    required String email,
    required String message,
  }) async {
    const String serviceId = 'service_2fhnump';
    const String templateId = 'template_muqk6fn';
    const String userId = '5J0WOUl5BTfeKLH99';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      setState(() {
        _isLoading = true;
      });

      // Create the body for the email request
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "service_id": serviceId,
              "template_id": templateId,
              "user_id": userId,
              "template_params": {
                "name": name,
                "email": email,
                "message": message,
              },
            }),
          )
          .timeout(Duration(seconds: 10), onTimeout: () {
            throw Exception('Request timed out. Please try again later.');
          });

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email. Try again later.')),
        );
        debugPrint('Error response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      // Ensure loading spinner stops after the request completes
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(labelText: 'Message'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          await sendEmail(
                            name: _nameController.text,
                            email: _emailController.text,
                            message: _messageController.text,
                          );
                        }
                      },
                      child: Text('Send'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: ContactForm(),
  ));
}
