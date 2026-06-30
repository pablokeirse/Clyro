import 'package:dio/dio.dart';

/// Thin client around the CLYRO FastAPI backend.
/// Point [baseUrl] at your backend (use 10.0.2.2 instead of localhost
/// when running on the Android emulator).
class ApiService {
  ApiService._internal()
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ));

  static final ApiService instance = ApiService._internal();

  static const String baseUrl = 'http://localhost:8000';

  final Dio dio;
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Options get _authOptions =>
      Options(headers: _token == null ? {} : {'Authorization': 'Bearer $_token'});

  // ---- Auth ----

  Future<Map<String, dynamic>> register(String name, String email, String password, String phone, String address, String city, String state, String zip) async {
    final res = await dio.post('/api/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'phone_number': phone,
      'address': address,
      'city': city,
      'state': state,
    });
    _token = res.data['access_token'];
    return res.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    _token = res.data['access_token'];
    return res.data;
  }

  // ---- Google Auth ----

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
      try {
        // 1. Changed _dio to dio, and used your standard path formatting
        final res = await dio.post(
          '/api/auth/google', 
          data: {'id_token': idToken},
        );
        
        // 2. Dio parses the JSON data automatically into res.data
        final data = res.data;
        
        // 3. Save the token exactly like you do in login() and register()
        _token = data['access_token'];
        
        return data;
      } catch (e) {
        throw Exception('Network error during Google authentication: $e');
      }
    }

  // ---- Account ----

  Future<Map<String, dynamic>> getMe() async {
    final res = await dio.get('/api/users/me', options: _authOptions);
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> updateMe({String? name}) async {
    final res = await dio.put(
      '/api/users/me',
      data: {if (name != null) 'name': name},
      options: _authOptions,
    );
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> requestPasswordReset(String email) async {
    await dio.post('/api/auth/forgot-password', data: {'email': email});
  }

  // ---- AI chat ----

  Future<String> sendChatMessage(String message) async {
    final res = await dio.post(
      '/api/ai/chat',
      data: {'message': message},
      options: _authOptions,
    );
    return res.data['reply']['content'] as String;
  }

  Future<List<Map<String, dynamic>>> chatHistory() async {
    final res = await dio.get('/api/ai/chat/history', options: _authOptions);
    return List<Map<String, dynamic>>.from(res.data);
  }

  // ---- Services search ----

  Future<List<Map<String, dynamic>>> searchProviders({
    String? category,
    double radiusKm = 5,
    double? lat,
    double? lng,
  }) async {
    final res = await dio.get(
      '/api/services',
      queryParameters: {
        if (category != null) 'category': category,
        'radius_km': radiusKm,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      },
      options: _authOptions,
    );
    return List<Map<String, dynamic>>.from(res.data);
  }
}