import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lad10/page/show_produsct.dart';
import 'package:shared_preferences/shared_preferences.dart';
// 1. ต้อง Import ไฟล์ปลายทางเสมอ


class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    if (username.text.isEmpty || password.text.isEmpty) return;

    setState(() => isLoading = true);

    try {
      var body = jsonEncode({
        "username": username.text,
        "password": password.text,
      });

      var url = Uri.parse("http://10.0.2.2:3000/api/auth/login");
      var response = await http.post(
        url,
        body: body,
        headers: {HttpHeaders.contentTypeHeader: "application/json"},
      );

      debugPrint(response.body);

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', result['accessToken']);

        // ✅ 2. คำสั่งเด้งไปหน้า show_produsct.dart
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ShowProductPage()),
        );
      } else {
        _showSnackBar("Login Failed!");
      }
    } catch (e) {
      _showSnackBar("Error connecting to server: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, color: Colors.red, size: 60),
            const SizedBox(height: 30),
            TextField(
              controller: username,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Username", labelStyle: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: password,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
                child: isLoading ? const CircularProgressIndicator() : const Text("ENTER THE BATTLE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController username = TextEditingController();
//   final TextEditingController password = TextEditingController();
//   bool isLoading = false;

//   Future<void> login() async {
//     if (username.text.isEmpty || password.text.isEmpty) return;

//     setState(() => isLoading = true);

//     debugPrint(username.text);

//     try {
//       var body = jsonEncode({
//         "username": username.text,
//         "password": password.text,
//       });

//       var url = Uri.parse("http://10.0.2.2:3000/api/auth/login");
//       var response = await http.post(
//         url,
//         body: body,
//         headers: {HttpHeaders.contentTypeHeader: "application/json"},
//       );

//       debugPrint(response.body);

//       // if (response.statusCode == 200) {
//       //   var result = jsonDecode(response.body);
//       //   SharedPreferences prefs = await SharedPreferences.getInstance();
//       //   await prefs.setString('token', result['token']);

//       //   if (!mounted) return;

//       //   // ✅ 2. คำสั่งเด้งไปหน้า show_produsct.dart
//       //   Navigator.pushReplacement(
//       //     context,
//       //     MaterialPageRoute(builder: (context) => const ShowProductPage()),
//       //   );
//       // } else {
//       //   _showSnackBar("Login Failed!");
//       // }
//     } catch (e) {
//       _showSnackBar("Error connecting to server");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void _showSnackBar(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D0D0D),
//       body: Padding(
//         padding: const EdgeInsets.all(25.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.shield, color: Colors.red, size: 60),
//             const SizedBox(height: 30),
//             TextField(
//               controller: username,
//               style: const TextStyle(color: Colors.white),
//               decoration: const InputDecoration(labelText: "Username", labelStyle: TextStyle(color: Colors.red)),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: password,
//               obscureText: true,
//               style: const TextStyle(color: Colors.white),
//               decoration: const InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.red)),
//             ),
//             const SizedBox(height: 40),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : login,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
//                 child: isLoading ? const CircularProgressIndicator() : const Text("ENTER THE BATTLE"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }