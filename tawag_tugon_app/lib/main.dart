import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  // Variables to hold our database state
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshContacts(); // Load data the second the screen opens
  }

  // --- 3. The Read Operation ---
  Future<void> _refreshContacts() async {
    final data = await DatabaseHelper.instance.getContacts();
    setState(() {
      _contacts = data;
      _isLoading = false;
    });
  }

  // --- 4. Temporary Write Operation (For testing) ---
  Future<void> _seedDummyData() async {
    await DatabaseHelper.instance.insertContact({
      'name': 'Local DB Police (Test)',
      'phone_number': '0917-999-0000',
      'category': 'Police',
      'priority': 10,
      'protocol': 'tel',
      'tenant_id': 1,
    });
    _refreshContacts(); // Tell the UI to redraw with the new row
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
      ),
      // --- 5. Conditional UI based on Database State ---
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? const Center(
              child: Text('Database is empty. Tap + to test SQLite.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                // We map the database row directly to the UI card
                return _buildContactCard(
                  contact['name'],
                  contact['phone_number'],
                  Icons.local_police, // Hardcoded icon for now
                  Colors.blue[700]!,
                );
              },
            ),
      // The temporary button to test writing to SQLite
      floatingActionButton: FloatingActionButton(
        onPressed: _seedDummyData,
        child: const Icon(Icons.add),
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
