import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> book; // ต้องรับข้อมูลหนังสือเล่มที่จะแก้ไขมาด้วย

  const EditProductPage({super.key, required this.book});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  // 1. สร้าง Controller สำหรับรับค่า
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // 2. นำข้อมูลเดิมที่รับมา ใส่เข้าไปใน TextField ทันทีที่เปิดหน้า
    titleController.text = widget.book['title']?.toString() ?? "";
    authorController.text = widget.book['author']?.toString() ?? "";
    yearController.text = widget.book['published_year']?.toString() ?? "";
  }

  // 3. ฟังก์ชันสำหรับ Update ข้อมูล (PUT Method)
  Future<void> updateBook() async {
    if (titleController.text.isEmpty || authorController.text.isEmpty || yearController.text.isEmpty) {
      _showSnackBar("กรุณากรอกข้อมูลให้ครบถ้วน");
      return;
    }

    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // ดึง accessToken ที่เก็บไว้ตอน Login

      int id = widget.book['id']; // ดึง ID ของหนังสือเล่มนี้
      var url = Uri.parse("http://10.0.2.2:3000/api/books/$id");

      var body = jsonEncode({
        "title": titleController.text,
        "author": authorController.text,
        "published_year": int.tryParse(yearController.text) ?? 0,
      });

      // ใช้ http.put สำหรับการแก้ไขข้อมูล (ตามคู่มือหน้า 43)
      var response = await http.put(
        url,
        body: body,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        _showSnackBar("แก้ไขข้อมูลสำเร็จ");
        Navigator.pop(context, true); // ปิดหน้าและส่งค่า true เพื่อบอกหน้า List ให้ Refresh
      } else {
        _showSnackBar("ไม่สามารถแก้ไขได้ (Error: ${response.statusCode})");
      }
    } catch (e) {
      _showSnackBar("เกิดข้อผิดพลาด: $e");
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
      appBar: AppBar(
        title: const Text("แก้ไขข้อมูลหนังสือ"),
        backgroundColor: Colors.red.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.edit_note, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "ชื่อหนังสือ", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: "ผู้แต่ง", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "ปีที่พิมพ์ (ค.ศ.)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateBook,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("บันทึกการแก้ไข", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}