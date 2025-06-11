import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/utils/req/request.dart';

class AddRequestPage extends StatefulWidget {
  final String accessToken;
  final VoidCallback? onRequestCreated;

  const AddRequestPage({
    Key? key,
    required this.accessToken,
    this.onRequestCreated,
  }) : super(key: key);

  @override
  State<AddRequestPage> createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isProcessing = false;

  String? get dateStr =>
      selectedDate != null
          ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
          : null;

  String? get startTimeStr =>
      startTime != null
          ? "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00"
          : null;

  String? get endTimeStr =>
      endTime != null
          ? "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00"
          : null;

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(primary: const Color(0xFF7BAFD4)),
            ),
            child: child!,
          ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(primary: const Color(0xFF7BAFD4)),
            ),
            child: child!,
          ),
    );
    if (picked != null)
      setState(() => isStart ? startTime = picked : endTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        title: Text(
          "요청 생성",
          style: TextStyle(
            fontSize: 17.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7BAFD4),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 제목
              TextFormField(
                decoration: InputDecoration(
                  labelText: "제목",
                  prefixIcon: const Icon(Icons.edit, color: Color(0xFF7BAFD4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (v) => title = v,
                validator: (v) => v == null || v.isEmpty ? "제목을 입력하세요" : null,
              ),
              SizedBox(height: 2.h),
              // 설명
              TextFormField(
                decoration: InputDecoration(
                  labelText: "설명",
                  prefixIcon: const Icon(Icons.notes, color: Color(0xFF7BAFD4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
                onChanged: (v) => description = v,
                validator: (v) => v == null || v.isEmpty ? "설명을 입력하세요" : null,
              ),
              SizedBox(height: 2.h),
              // 날짜
              GestureDetector(
                onTap: pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "날짜 선택",
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF7BAFD4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      hintText: "날짜를 선택하세요",
                    ),
                    controller: TextEditingController(text: dateStr ?? ""),
                    validator: (_) => dateStr == null ? "날짜를 선택하세요" : null,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // 시작 시간
              GestureDetector(
                onTap: () => pickTime(true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "시작 시간",
                      prefixIcon: const Icon(
                        Icons.access_time,
                        color: Color(0xFF7BAFD4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      hintText: "시작 시간을 선택하세요",
                    ),
                    controller: TextEditingController(text: startTimeStr ?? ""),
                    validator:
                        (_) => startTimeStr == null ? "시작 시간을 선택하세요" : null,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // 종료 시간
              GestureDetector(
                onTap: () => pickTime(false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "종료 시간",
                      prefixIcon: const Icon(
                        Icons.access_time,
                        color: Color(0xFF7BAFD4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      hintText: "종료 시간을 선택하세요",
                    ),
                    controller: TextEditingController(text: endTimeStr ?? ""),
                    validator:
                        (_) => endTimeStr == null ? "종료 시간을 선택하세요" : null,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              // 등록 버튼
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7BAFD4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      isProcessing
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => isProcessing = true);
                              final result = await createRequest(
                                widget.accessToken,
                                title,
                                description,
                                dateStr!,
                                startTimeStr!,
                                endTimeStr!,
                              );
                              setState(() => isProcessing = false);
                              if (result.statusCode == 201) {
                                widget.onRequestCreated?.call();
                                Navigator.pop(context, true);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  child:
                      isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "요청 등록",
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
