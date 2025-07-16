import 'dart:io';
import 'dart:convert';

void main() async {
  print('Hydration Tracker - Service Status Check\n');

  final services = [
    {'name': 'Auth Service', 'url': 'http://localhost:8081/api/v1/register', 'method': 'POST'},
    {'name': 'Hydration Service', 'url': 'http://localhost:8082/api/v1/stats', 'method': 'GET'},
  ];

  for (final service in services) {
    await checkService(service['name']!, service['url']!, service['method']!);
  }

  print('\n=== Summary ===');
  print('If all services are running, you can:');
  print('1. Start Flutter app: flutter run -d chrome');
  print('2. Test API: dart test_api.dart');
  print('3. View Swagger docs:');
  print('   - Auth: http://localhost:8081/swagger/');
  print('   - Hydration: http://localhost:8082/swagger/');
}

Future<void> checkService(String name, String url, String method) async {
  print('Checking $name...');
  
  try {
    final client = HttpClient();
    final request = await client.openUrl(method, Uri.parse(url));
    
    // Add minimal headers for hydration service
    if (name.contains('Hydration')) {
      request.headers.set('Authorization', 'Bearer test-token');
    }
    
    final response = await request.close();
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 500) {
      print('✅ $name is running (Status: $statusCode)');
    } else {
      print('❌ $name returned status: $statusCode');
    }
    
    client.close();
  } catch (e) {
    if (e.toString().contains('Connection refused')) {
      print('❌ $name is not running');
      print('   Start it with: cd backend && go run main.go');
    } else {
      print('❌ $name error: $e');
    }
  }
  
  print('');
} 