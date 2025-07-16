import 'dart:io';
import 'dart:convert';

void main() async {
  print('Testing Hydration Tracker API...\n');
  print('Platform: ${Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Web'}\n');

  // Test auth service
  await testAuthService();
  
  // Test hydration service
  await testHydrationService();
}

Future<void> testAuthService() async {
  print('=== Testing Auth Service (Port 8081) ===');
  
  try {
    // Test registration
    print('1. Testing registration...');
    final registerResponse = await testEndpoint(
      'http://localhost:8081/api/v1/register',
      'POST',
      {
        'username': 'testuser',
        'email': 'test@example.com',
        'password': '123456'
      },
    );
    print('Registration response: $registerResponse\n');

    // Test login
    print('2. Testing login...');
    final loginResponse = await testEndpoint(
      'http://localhost:8081/api/v1/login',
      'POST',
      {
        'username': 'testuser',
        'password': '123456'
      },
    );
    print('Login response: $loginResponse\n');

    if (loginResponse['token'] != null) {
      final token = loginResponse['token'];
      
      // Test profile
      print('3. Testing profile...');
      final profileResponse = await testEndpoint(
        'http://localhost:8081/api/v1/profile',
        'GET',
        null,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Profile response: $profileResponse\n');
    }
  } catch (e) {
    print('Auth service error: $e\n');
  }
}

Future<void> testHydrationService() async {
  print('=== Testing Hydration Service (Port 8082) ===');
  
  try {
    // First get a token
    final loginResponse = await testEndpoint(
      'http://localhost:8081/api/v1/login',
      'POST',
      {
        'username': 'testuser',
        'password': '123456'
      },
    );

    if (loginResponse['token'] != null) {
      final token = loginResponse['token'];
      
      // Test create entry
      print('1. Testing create hydration entry...');
      final createResponse = await testEndpoint(
        'http://localhost:8082/api/v1/entries',
        'POST',
        {
          'amount': 250,
          'type': 'вода'
        },
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Create entry response: $createResponse\n');

      // Test get entries
      print('2. Testing get entries...');
      final entriesResponse = await testEndpoint(
        'http://localhost:8082/api/v1/entries',
        'GET',
        null,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Get entries response: $entriesResponse\n');

      // Test get stats
      print('3. Testing get stats...');
      final statsResponse = await testEndpoint(
        'http://localhost:8082/api/v1/stats',
        'GET',
        null,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Get stats response: $statsResponse\n');

      // Test update goal
      print('4. Testing update goal...');
      final goalResponse = await testEndpoint(
        'http://localhost:8082/api/v1/goal',
        'PUT',
        {
          'goal': 2500
        },
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Update goal response: $goalResponse\n');
    }
  } catch (e) {
    print('Hydration service error: $e\n');
  }
}

Future<Map<String, dynamic>> testEndpoint(
  String url,
  String method,
  Map<String, dynamic>? body, {
  Map<String, String>? headers,
}) async {
  final client = HttpClient();
  
  try {
    final request = await client.openUrl(method, Uri.parse(url));
    
    if (headers != null) {
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
    }
    
    if (body != null) {
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(body));
    }
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('HTTP ${response.statusCode}: $responseBody');
    }
  } finally {
    client.close();
  }
} 