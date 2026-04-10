import 'dart:ui';
import '../../core/constants/app_colors.dart';

enum RequestStatus {
  pending,
  accepted,
  rejected,
}

class RequestModel {
  final int id;
  final int opportunityId;
  final String opportunityTitle;
  final String companyName;
  final RequestStatus status;
  final String? rejectionReason;
  final String createdAt;

  RequestModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.companyName,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      opportunityId: json['opportunity_id'],
      opportunityTitle: json['opportunity_title'],
      companyName: json['company_name'],
      status: _parseStatus(json['status']),
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'],
    );
  }

  static RequestStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }

  Color get statusColor {
    switch (status) {
      case RequestStatus.pending:
        return AppColors.pending;
      case RequestStatus.accepted:
        return AppColors.success;
      case RequestStatus.rejected:
        return AppColors.error;
    }
  }
}