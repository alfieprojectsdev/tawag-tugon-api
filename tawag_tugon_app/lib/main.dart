import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // <-- NEW: For parsing the JSON
import 'package:http/http.dart' as http; // <-- NEW: The HTTP client
import 'db_helper.dart'; // <-- 1. Import your new database engine

void main() {
  runApp(const TawagTugonApp());
}

class TawagTugonApp extends StatelessWidget {
  const TawagTugonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tawag-Tugon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0033A0)),
        useMaterial3: true,
      ),
      home: const SpeedDialScreen(), // This is now a StatefulWidget
    );
  }
}

// --- 2. Upgraded to StatefulWidget ---
class SpeedDialScreen extends StatefulWidget {
  const SpeedDialScreen({super.key});

  @override
  State<SpeedDialScreen> createState() => _SpeedDialScreenState();
}

class _SpeedDialScreenState extends State<SpeedDialScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

  Future<void> _refreshContacts() async {
    final data = await DatabaseHelper.instance.getContacts();
    setState(() {
      _contacts = data;
      _isLoading = false;
    });
  }

  // --- THE NEW SYNC FUNCTION ---
  Future<void> _syncWithServer() async {
    setState(() => _isLoading = true); // Show the loading spinner

    try {
      // ⚠️ REPLACE THIS IP AND ENDPOINT WITH YOUR ACTUAL THINKPAD IP AND FASTAPI ROUTE
      // Make sure your FastAPI server is running! (uvicorn main:app --host 0.0.0.0 --port 8000)
      final String apiUrl =
          'http://192.168.1.73:8000/api/v1/public/qc/manifest';

      print("Fetching manifest from $apiUrl...");
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> jsonList = jsonResponse['contacts'] ?? [];

        // Clear the old cache to prevent duplicates when syncing
        await DatabaseHelper.instance.clearContacts();

        // Loop through the JSON and dump it into SQLite
        for (var item in jsonList) {
          await DatabaseHelper.instance.insertContact({
            'name': item['name'],
            'phone_number': item['phone_number'],
            'category': item['category'] ?? 'General',
            'priority': item['priority'] ?? 0,
            'protocol': item['protocol'] ?? 'tel',
            'tenant_id': item['tenant_id'] ?? 1,
          });
        }
        print(
          "Successfully synced ${jsonList.length} contacts to offline cache!",
        );
      } else {
        print("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // If the phone has no internet, it will fail here.
      // But because we are offline-first, the app won't crash! It just keeps using the old SQLite data.
      print("Network failed, relying on offline cache. Error: $e");
    }

    // Tell the UI to redraw with the fresh SQLite data
    await _refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // A manual sync button in the top right corner
          IconButton(icon: const Icon(Icons.sync), onPressed: _syncWithServer),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? const Center(
              child: Text(
                'Database is empty. Tap the Sync icon to download data.',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return _buildContactCard(
                  contact['name'],
                  contact['phone_number'],
                  Icons.local_police,
                  Colors.blue[700]!,
                );
              },
            ),
    );
  }

  Widget _buildContactCard(
    String name,
    String number,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(number),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () async {
            final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
            final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

            if (await canLaunchUrl(launchUri)) {
              await launchUrl(launchUri);
            } else {
              print("ERROR: Could not launch dialer for $number");
            }
          },
        ),
      ),
    );
  }
}
