import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = 'http://192.168.1.12:5000/detect';

  static Future<Map<String, dynamic>> detectObjects(String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = jsonDecode(responseData);

        print("API Response: $decodedData"); // Debugging log

        if (decodedData == null || !decodedData.containsKey('detections')) {
          print("No objects detected in image.");
          return {
            "detections": [],
            "objectCounts": {},
            "message": decodedData["message"] ?? "No objects detected."
          };
        }

        List<Map<String, dynamic>> detections = [];
        Map<String, int> objectCounts = {};

        if (decodedData["detections"] is List) {
          for (var detection in decodedData["detections"]) {
            if (detection is Map<String, dynamic>) {
              double confidence = (detection["confidence"] as num?)?.toDouble() ?? 0.0;
              if (confidence >= 30.0) { // ✅ Lowered confidence threshold from 80% to 50%
                detections.add(detection);
                String label = detection["label"] ?? "Unknown";
                objectCounts[label] = (objectCounts[label] ?? 0) + 1;
              }
            } else {
              print("Invalid detection format: $detection");
            }
            print("Full API Response: ${responseData}");

          }
        } else {
          print("Unexpected format for detections: ${decodedData["detections"]}");
        }

        return {"detections": detections, "objectCounts": objectCounts};
      } else {
        print("Error: ${response.statusCode}");
        return {
          "detections": [],
          "objectCounts": {},
          "error": "API returned status ${response.statusCode}"
        };
      }
    } catch (e) {
      print("Error in API call: $e");
      return {"detections": [], "objectCounts": {}, "error": e.toString()};
    }

    
  }
  
}
