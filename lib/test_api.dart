import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({Key? key}) : super(key: key);

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  String _result = 'Press button to test API';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing...';
    });

    try {
      // اختبار 1: الاتصال بالإنترنت
      final googleResult = await InternetAddress.lookup('google.com');
      if (googleResult.isNotEmpty && googleResult[0].rawAddress.isNotEmpty) {
        setState(() {
          _result = '✅ Internet: Connected\n';
        });
      }

      // اختبار 2: الاتصال بالـ API
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/education/test'), // غير الرابط حسب API الخاص بك
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _result += '✅ API Status: ${response.statusCode}\n';
        _result += '📦 Response: ${response.body}';
      });
    } on SocketException catch (e) {
      setState(() {
        _result = '❌ Network Error:\n$e\n\nCheck your API URL!';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Error:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _result,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test API Connection'),
            ),
          ],
        ),
      ),
    );
  }
}