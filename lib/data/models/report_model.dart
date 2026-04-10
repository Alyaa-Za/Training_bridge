class ReportModel {
  final int id;
  final int weekNumber;
  final String content;
  final String? attachment;
  final String? supervisorFeedback;
  final String submittedAt;

  ReportModel({
    required this.id,
    required this.weekNumber,
    required this.content,
    this.attachment,
    this.supervisorFeedback,
    required this.submittedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      weekNumber: json['week_number'],
      content: json['content'],
      attachment: json['attachment'],
      supervisorFeedback: json['supervisor_feedback'],
      submittedAt: json['submitted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_number': weekNumber,
      'content': content,
      'attachment': attachment,
      'supervisor_feedback': supervisorFeedback,
      'submitted_at': submittedAt,
    };
  }
}