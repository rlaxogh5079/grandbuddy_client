import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class YouthRequestActionButton extends StatelessWidget {
  final bool isMatchedByOther;
  final bool hasApplied;
  final bool isMatchedMine;
  final bool isProcessing;
  final VoidCallback? onApply;
  final VoidCallback? onCancel;

  const YouthRequestActionButton({
    super.key,
    required this.isMatchedByOther,
    required this.hasApplied,
    required this.isMatchedMine,
    required this.isProcessing,
    this.onApply,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (isMatchedByOther) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          "다른 사람과 이미 매칭된 요청입니다.",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
            color: Colors.white,
          ),
        ),
      );
    }

    if (hasApplied) {
      if (isMatchedMine) {
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            "매칭된 상태에서는 취소 불가",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
              color: Colors.white,
            ),
          ),
        );
      } else {
        return ElevatedButton(
          onPressed: isProcessing ? null : onCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child:
              isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                    "신청 취소",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                      color: Colors.white,
                    ),
                  ),
        );
      }
    }

    // 신청 안 했을 때
    return ElevatedButton(
      onPressed: isProcessing ? null : onApply,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7BAFD4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child:
          isProcessing
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                "신청하기",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.sp,
                  color: Colors.white,
                ),
              ),
    );
  }
}

class SeniorMatchActionButtons extends StatelessWidget {
  final bool show;
  final bool isProcessing;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const SeniorMatchActionButtons({
    super.key,
    required this.show,
    required this.isProcessing,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(
            "매칭이 성사된 요청입니다. 완료 또는 취소를 선택하세요.",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              // 완료 버튼
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.check_circle, color: Colors.white, size: 26),
                  label:
                      isProcessing
                          ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                          : Text(
                            "완료 처리",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: isProcessing ? null : onComplete,
                ),
              ),
              SizedBox(width: 16),
              // 취소 버튼
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.cancel, color: Colors.white, size: 26),
                  label:
                      isProcessing
                          ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                          : Text(
                            "요청 취소",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: isProcessing ? null : onCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
