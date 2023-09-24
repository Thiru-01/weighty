import 'dart:convert';

WeiData weiDataFromJson(String str) => WeiData.fromJson(json.decode(str));

String weiDataToJson(WeiData data) => json.encode(data.toJson());

class WeiData {
  final String weight;
  final String date;
  String? description;
  String? imagePath;

  WeiData({
    required this.weight,
    required this.date,
    required this.description,
    this.imagePath,
  });

  factory WeiData.fromJson(Map<String, dynamic> json) => WeiData(
        weight: json["weight"],
        date: json["date"],
        description: json["description"],
        imagePath: json["image_path"],
      );

  Map<String, dynamic> toJson() => {
        "weight": weight,
        "date": date,
        "description": description,
        "image_path": imagePath,
      };
  void setDownloadUrl({required String downloadUrl}) {
    imagePath = downloadUrl;
  }
}
