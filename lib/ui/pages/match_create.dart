import 'package:flutter/material.dart';

class GBCreateRequestPage extends StatefulWidget {
  @override
  _CreateRequestPageState createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<GBCreateRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final description = _descController.text;

      // 여기에 API 호출 (POST /request) 로직 추가
      print("요청 전송: $title, $description");

      // 예시: 성공 메시지
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('요청이 생성되었습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("도움 요청 생성")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "제목"),
                validator: (value) => value!.isEmpty ? "제목을 입력하세요" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: "설명"),
                validator: (value) => value!.isEmpty ? "설명을 입력하세요" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submitRequest, child: Text("요청 생성")),
            ],
          ),
        ),
      ),
    );
  }
}
