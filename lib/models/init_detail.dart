class InitDetail {
  final String googleApiKey;
  final int upgradeFlag;

  InitDetail({
    required this.googleApiKey,
    required this.upgradeFlag,
  });

  // Optional: Factory constructor for creating InitDetail from JSON
  factory InitDetail.fromJson(Map<String, dynamic> json) {
    return InitDetail(
      googleApiKey: json['googleApiKey'] as String,
      upgradeFlag: json['upgradeFlag'] as int,
    );
  }

  // Optional: Method to convert InitDetail to JSON
  Map<String, dynamic> toJson() {
    return {
      'googleApiKey': googleApiKey,
      'upgradeFlag': upgradeFlag,
    };
  }
}
