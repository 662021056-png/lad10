import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowProductPage extends StatefulWidget {
  const ShowProductPage({super.key});

  @override
  State<ShowProductPage> createState() => _ShowProductPageState();
}

class _ShowProductPageState extends State<ShowProductPage> {
  // 1. ฟังก์ชันดึงข้อมูลจาก API ตาราง books
  Future<List<dynamic>> fetchBooks() async {
    final url = Uri.parse('https://laravel-backend-cs.herokuapp.com/api/books');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // คืนค่าเป็นรายการข้อมูล JSON
    } else {
      throw Exception('โหลดข้อมูลล้มเหลว');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการหนังสือ'),
        backgroundColor: Colors.blue,
      ),
      // 2. ใช้ FutureBuilder เพื่อจัดการสถานะการรอข้อมูล
      body: FutureBuilder<List<dynamic>>(
        future: fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // กำลังโหลด
          } else if (snapshot.hasError) {
            return Center(child: Text('ข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลหนังสือ'));
          }
          

          // 3. แสดงข้อมูลในรูปแบบ List เมื่อข้อมูลมาถึง
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final book = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.book, color: Colors.blue),
                  title: Text(book['title'] ?? 'ไม่มีชื่อเรื่อง', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ผู้แต่ง: ${book['author']}'),
                  trailing: Text('${book['published_year']}'), // ปีที่พิมพ์ตามฐานข้อมูล
                ),
              );
            },
          );
        },
      ),
    );
  }
}