import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ElectricityInput extends StatefulWidget {
  final DateTime initialDate;

  const ElectricityInput({super.key, required this.initialDate});

  @override
  State<ElectricityInput> createState() => _ElectricityInputState();
}

class _ElectricityInputState extends State<ElectricityInput> {
  final TextEditingController _usageController = TextEditingController();

  // OCR 도구
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  void dispose() {
    _textRecognizer.close();
    _usageController.dispose();
    super.dispose();
  }

  // 카메라 또는 갤러리에서 이미지 가져와서 OCR 분석
  Future<void> _getImageAndProcess(ImageSource source) async {
    try {
      // 1. 이미지 가져오기 (카메라 or 갤러리)
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return; // 취소함

      // 2. ML Kit로 이미지 분석
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      String scannedText = recognizedText.text;
      print("🔍 분석된 텍스트: $scannedText"); // 로그 확인용

      // 3. 숫자 추출 (정규식)
      RegExp regExp = RegExp(r'\d+(\.\d+)?');
      Iterable<RegExpMatch> matches = regExp.allMatches(scannedText);

      if (matches.isNotEmpty) {
        // 가장 그럴싸한 숫자(예: 길이가 좀 긴 것)를 찾거나 첫 번째 것 선택
        String? number = matches.first.group(0);
        setState(() {
          _usageController.text = number ?? "";
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("숫자 인식 성공!")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("숫자를 찾지 못했습니다.")));
      }
    } catch (e) {
      print("OCR 에러: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("오류가 발생했습니다.")));
    }
  }

  //  서버 저장
  Future<void> _submit() async {
    // 1. 입력값 확인
    if (_usageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("⚠️ 사용량을 입력해주세요!")));
      return;
    }

    // 2. 로그인 정보(ID) 확인
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    // 👇 ID가 없으면 경고창 띄우기 (범인 색출!)
    if (userId == null || userId.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("로그인 필요"),
          content: const Text("로그인 정보가 없습니다.\n앱을 껐다가 다시 로그인해주세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("확인"),
            ),
          ],
        ),
      );
      return;
    }

    // 3. 데이터 준비
    String dateStr = DateFormat('yyyy-MM-dd').format(widget.initialDate);
    // 쉼표(,)가 있으면 제거하고 숫자로 변환 (예: 127,240 -> 127240)
    String cleanInput = _usageController.text.replaceAll(',', '');
    double usage = double.tryParse(cleanInput) ?? 0.0;

    // 4. 서버 전송
    final url = Uri.parse("http://10.0.2.2:8080/api/carbon/save");

    try {
      final response = await http.post(
        url,
        body: {
          "username": userId,
          "category": "Electricity",
          "type": "Home",
          "input": usage.toString(),
          "date": dateStr,
        },
      );

      print("서버 응답 코드: ${response.statusCode}");
      print("서버 응답 내용: ${response.body}");

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); // 성공! 창 닫기
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ 저장 성공!")));
      } else {
        // 실패 시 에러 메시지 보여주기
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("저장 실패: ${response.body}")));
      }
    } catch (e) {
      print("에러 발생: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("에러: 서버와 연결할 수 없습니다.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "⚡ 전기 사용량 입력",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _usageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "사용량 (kWh)",
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min, // 아이콘들만큼만 공간 차지
                children: [
                  // 1. 갤러리 버튼
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.green),
                    onPressed: () => _getImageAndProcess(ImageSource.gallery),
                    tooltip: "갤러리에서 불러오기",
                  ),
                  // 2. 카메라 버튼
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.blue),
                    onPressed: () => _getImageAndProcess(ImageSource.camera),
                    tooltip: "카메라로 찍기",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "* 사진 아이콘을 눌러 테스트용 고지서 이미지를 불러오세요.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text("기록하기", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
