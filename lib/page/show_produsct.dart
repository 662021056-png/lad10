import 'edit_produsct.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import หน้าที่เกี่ยวข้อง (ตรวจสอบชื่อไฟล์ให้ตรงกับในโปรเจกต์)
import 'loginpage.dart';
import 'app_produsct.dart'; 
import 'edit_produsct.dart';

class ShowProductPage extends StatefulWidget {
  const ShowProductPage({super.key});

  @override
  State<ShowProductPage> createState() => _ShowProductPageState();
}

class _ShowProductPageState extends State<ShowProductPage> {
  
  // 1. ฟังก์ชันดึงข้อมูลหนังสือ (GET) พร้อมแนบ Token
  Future<List<dynamic>> fetchBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // ดึง token ที่เก็บจาก result['accessToken']

    final url = Uri.parse('http://10.0.2.2:3000/api/books');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('โหลดข้อมูลล้มเหลว');
    }
  }

  // 2. ฟังก์ชันลบข้อมูล (DELETE) ตามคู่มือหน้า 46
  Future<void> deleteBook(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://10.0.2.2:3000/api/books/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {}); // รีเฟรชรายการ
      _showSnackBar("ลบหนังสือสำเร็จแล้ว");
    } else {
      _showSnackBar("ไม่สามารถลบได้");
    }
  }

  // 3. ฟังก์ชันออกจากระบบ (Logout) ตามคู่มือหน้า 47
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    if (!mounted) return;
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const Loginpage())
    );
  }

  // 4. แสดง Dialog ยืนยันการลบ ตามคู่มือหน้า 45
  void showDeleteDialog(int id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบหนังสือ "$title" ใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () {
              deleteBook(id);
              Navigator.pop(context);
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imperial Book List'),
        backgroundColor: Colors.red.shade900,
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลหนังสือในคลัง'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final book = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.menu_book, color: Colors.red, size: 40),
                  title: Text(
                    book['title'] ?? 'ไม่มีชื่อหนังสือ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    'ผู้แต่ง: ${book['author'] ?? "ไม่ระบุ"}\nปีที่พิมพ์: ${book['published_year'] ?? "ไม่ระบุ"}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ปุ่มแก้ไข (ไปหน้า edit_produsct.dart)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProductPage(book: book)),
                          ).then((value) {
                            if (value == true) setState(() {}); // รีเฟรชถ้ามีการบันทึก
                          });
                        },
                      ),
                      // ปุ่มลบ
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => showDeleteDialog(book['id'], book['title']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // ปุ่มเพิ่มหนังสือ (ไปหน้า app_produsct.dart)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AppProductPage()),
          ).then((value) {
            if (value == true) setState(() {}); // รีเฟรชถ้ามีการเพิ่มสำเร็จ
          });
        },
        backgroundColor: Colors.red.shade900,
        child: const Icon(Icons.add),
      ),
    );
  }
}