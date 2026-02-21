import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- 1. New Import

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
      home: const SpeedDialScreen(),
    );
  }
}

class SpeedDialScreen extends StatelessWidget {
  const SpeedDialScreen({super.key});

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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              "QUEZON CITY - DISTRICT 1",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildContactCard(
            "QCPD Station 1",
            "0917-123-4567",
            Icons.local_police,
            Colors.blue[700]!,
          ),
          _buildContactCard(
            "QC DRRMO",
            "122",
            Icons.emergency,
            Colors.red[700]!,
          ),

          // Note: "Viber Only" will fail the 'tel:' check, which is a great test for our error handling!
          _buildContactCard(
            "Brgy. Santo Cristo",
            "Viber Only",
            Icons.chat,
            Colors.purple[600]!,
          ),
        ],
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
            // --- 2. The Native Hardware Hook ---
            // Clean the number of dashes or spaces just in case
            final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
            final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

            // Ask the OS if there is an app that can handle 'tel:'
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
