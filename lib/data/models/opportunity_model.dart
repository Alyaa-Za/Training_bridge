class OpportunityModel {
  final int id;
  final String title;
  final String description;
  final String companyName;
  final String city;
  final String major;
  final String? startDate;
  final String? endDate;
  final int? duration;
  final bool isActive;
  final String? logo;

  OpportunityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    required this.city,
    required this.major,
    this.startDate,
    this.endDate,
    this.duration,
    this.isActive = true,
    this.logo,
  });

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    return OpportunityModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      companyName: json['company_name'],
      city: json['city'],
      major: json['major'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      duration: json['duration'],
      isActive: json['is_active'] ?? true,
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'company_name': companyName,
      'city': city,
      'major': major,
      'start_date': startDate,
      'end_date': endDate,
      'duration': duration,
      'is_active': isActive,
      'logo': logo,
    };
  }
}