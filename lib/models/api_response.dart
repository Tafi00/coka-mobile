class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String message;

  ApiResponse({
    required this.isSuccess,
    required this.data,
    required this.message,
  });
}

class HiddenStagesResponse {
  final List<String>? hiddenStages;
  final List<String>? hiddenGroups;

  HiddenStagesResponse({
    this.hiddenStages,
    this.hiddenGroups,
  });

  factory HiddenStagesResponse.fromJson(Map<String, dynamic> json) => HiddenStagesResponse(
    hiddenStages: json['hiddenStages'] != null ? List<String>.from(json['hiddenStages']) : null,
    hiddenGroups: json['hiddenGroups'] != null ? List<String>.from(json['hiddenGroups']) : null,
  );
} 