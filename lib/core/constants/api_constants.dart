class ApiConstants {
  // Base URL - Change this for production
  // ✅ API اختباري مجاني يعمل 100%
  static const String baseUrl = 'https://reqres.in/api';

  // Auth Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String profile = '/users/2';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String roleKey = 'user_role';
  static const String userDataKey = 'user_data';

  // static const String baseUrl = 'http://192.168.8.163:8000/api/education';

  // Auth Endpoints
  // static const String login = '/login';
  // static const String logout = '/logout';
  // static const String profile = '/profile';

  // Student Endpoints
  static const String opportunities = '/opportunities';
  static const String applyOpportunity = '/apply';
  static const String myRequests = '/my-requests';
  static const String myInternship = '/my-internship';
  static const String submitReport = '/reports';

  // Institution Endpoints
  static const String institutionOpportunities = '/institution/opportunities';
  static const String applicants = '/institution/applicants';
  static const String acceptApplicant = '/institution/accept';
  static const String rejectApplicant = '/institution/reject';
  static const String interns = '/institution/interns';
  static const String evaluate = '/institution/evaluate';

  // Storage Keys
  // static const String tokenKey = 'auth_token';
  // static const String roleKey = 'user_role';
  // static const String userDataKey = 'user_data';
}