import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppProductPage extends StatefulWidget {
  final Map<String, dynamic>? book; // รับข้อมูลมาเพื่อแก้ไข

  const AppProductPage({super.key, this.book});

  @override
  State<AppProductPage> createState() => _AppProductPageState();
}

class _AppProductPageState extends State<AppProductPage> {
  // 1. เปลี่ยนชื่อ Controller ให้ตรงกับงานใหม่
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // ถ้ามีข้อมูลส่งมา (โหมดแก้ไข) ให้เอาค่าเดิมใส่ในช่องกรอก
    if (widget.book != null) {
      titleController.text = widget.book!['title']?.toString() ?? "";
      authorController.text = widget.book!['author']?.toString() ?? "";
      yearController.text = widget.book!['published_year']?.toString() ?? "";
    }
  }

  Future<void> saveBook() async {
    if (titleController.text.isEmpty || authorController.text.isEmpty || yearController.text.isEmpty) {
      _showSnackBar("กรุณากรอกข้อมูลให้ครบทุกช่อง");
      return;
    }

    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      // 2. ปรับโครงสร้าง JSON ให้ส่ง author และ published_year
      var body = jsonEncode({
        "title": titleController.text,
        "author": authorController.text,
        "published_year": int.parse(yearController.text), // แปลงเป็นตัวเลข
      });

      http.Response response;
      
      if (widget.book == null) {
        // เพิ่มใหม่
        var url = Uri.parse("http://10.0.2.2:3000/api/books");
        response = await http.post(url, body: body, headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        });
      } else {
        // แก้ไข
        var id = widget.book!['id'];
        var url = Uri.parse("http://10.0.2.2:3000/api/books/$id");
        response = await http.put(url, body: body, headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        });
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        _showSnackBar("บันทึกข้อมูลเรียบร้อย");
        Navigator.pop(context, true); // กลับไปหน้า List และแจ้งให้ Refresh
      } else {
        _showSnackBar("เซิร์ฟเวอร์ตอบกลับผิดพลาด: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("เกิดข้อผิดพลาด: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? "เพิ่มหนังสือ" : "แก้ไขหนังสือ"),
        backgroundColor: Colors.red.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "ชื่อหนังสือ", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: "ชื่อผู้แต่ง", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "ปีที่พิมพ์", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveBook,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("บันทึกข้อมูล", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}