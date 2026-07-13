import 'package:intl/intl.dart'; // <-- NEW: For date formatting
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // <-- NEW: For parsing the JSON
import 'package:http/http.dart' as http; // <-- NEW: The HTTP client
import 'db_helper.dart'; // <-- 1. Import your new database engine
import 'env.dart'; // <-- Import the auto-generated env file

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
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final contactsData = await DatabaseHelper.instance.getContacts();
    final newsData = await DatabaseHelper.instance.getNews();
    setState(() {
      _contacts = contactsData;
      _news = newsData;
      _isLoading = false;
    });
  }

  // --- THE NEW SYNC FUNCTION ---
  Future<void> _syncWithServer() async {
    setState(() => _isLoading = true); // Show the loading spinner

    try {
      // ⚠️ REPLACE THIS IP AND ENDPOINT WITH YOUR ACTUAL THINKPAD IP AND FASTAPI ROUTE
      // Make sure your FastAPI server is running! (uvicorn main:app --host 0.0.0.0 --port 8000)
      final String baseUrl = 'http://${Env.serverIp}:8000/api/v1/public/qc';
      final String manifestUrl = '$baseUrl/manifest';
      final String newsUrl = '$baseUrl/news';

      print("Fetching manifest from $manifestUrl...");
      final responseManifest = await http.get(Uri.parse(manifestUrl));

      if (responseManifest.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          responseManifest.body,
        );
        final List<dynamic> jsonList = jsonResponse['contacts'] ?? [];

        await DatabaseHelper.instance.clearContacts();
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
        print("Successfully synced ${jsonList.length} contacts.");
      } else {
        print("Manifest server error: ${responseManifest.statusCode}");
      }

      print("Fetching news from $newsUrl...");
      final responseNews = await http.get(Uri.parse(newsUrl));

      if (responseNews.statusCode == 200) {
        final List<dynamic> jsonNewsList = json.decode(responseNews.body);

        // REMOVED clearNews() to prevent nuking the database and wiping archive state
        for (var item in jsonNewsList) {
          await DatabaseHelper.instance.insertNews({
            'title': item['title'] ?? 'No Title Provided',
            'content': item['content'] ?? 'No content available.',
            'source_url': item['source_url'] ?? '',
            'published_date': item['published_date'] ?? '',
            'tenant_id': item['tenant_id'] ?? 1,
          });
        }
        print("Successfully synced ${jsonNewsList.length} news articles.");
      } else {
        print("News server error: ${responseNews.statusCode}");
      }
    } catch (e) {
      // If the phone has no internet, it will fail here.
      // But because we are offline-first, the app won't crash! It just keeps using the old SQLite data.
      print("Network failed, relying on offline cache. Error: $e");
    }

    // Tell the UI to redraw with the fresh SQLite data
    await _refreshData();
  }

  // Helper to format the ugly ISO string
  String _formatDate(dynamic rawDateParam) {
    if (rawDateParam == null) return '';
    final String rawDate = rawDateParam.toString();
    if (rawDate.isEmpty) return '';
    try {
      final parsedDate = DateTime.parse(rawDate);
      // Formats to: "Feb 21, 2026, 1:07 PM"
      return DateFormat('MMM d, yyyy, h:mm a').format(parsedDate);
    } catch (e) {
      return rawDate; // Fallback to raw string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Emergency Contacts' : 'Local News',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
          : _selectedIndex == 0
          ? _buildContactsWidget()
          : _buildNewsWidget(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone),
            label: 'Speed Dial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Local News',
          ),
        ],
      ),
    );
  }

  Widget _buildContactsWidget() {
    if (_contacts.isEmpty) {
      return const Center(
        child: Text('Database is empty. Tap the Sync icon to download data.'),
      );
    }
    return ListView.builder(
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
    );
  }

  Widget _buildNewsWidget() {
    if (_news.isEmpty) {
      return const Center(
        child: Text('No news available. Tap the Sync icon to download data.'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _news.length,
      itemBuilder: (context, index) {
        final article = _news[index];
        final url = article['source_url']?.toString() ?? '';

        // Generate a unique key for the Dismissible to track the specific card
        final uniqueKey =
            article['id']?.toString() ?? article['title'] ?? index.toString();

        return Dismissible(
          key: Key(uniqueKey),
          direction: DismissDirection.endToStart, // Swipe right-to-left
          background: Container(
            color: Colors.red.shade400,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.only(
              bottom: 12,
            ), // Match the card's margin
            child: const Icon(Icons.delete_sweep, color: Colors.white),
          ),
          onDismissed: (direction) async {
            // Remove the item from the local UI state
            setState(() {
              _news.removeAt(index);
            });

            // Actually archive it in the database so it stays hidden across sessions
            await DatabaseHelper.instance.archiveNews(article['id']);

            // Show a quick visual confirmation
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Announcement archived safely'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailScreen(
                      title: article['title'] ?? 'Untitled',
                      content: article['content'] ?? 'No content available.',
                      date: _formatDate(article['published_date']),
                      sourceUrl: url,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'] ?? 'Untitled',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (article['published_date'] != null &&
                        article['published_date'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                        child: Text(
                          _formatDate(article['published_date']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 8),
                    Text(
                      article['content'] ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

            // Don't gate on canLaunchUrl: with Android 11+ package
            // visibility it reports false even when a handler exists.
            try {
              await launchUrl(launchUri);
            } catch (e) {
              debugPrint("ERROR: Could not launch dialer for $number: $e");
            }
          },
        ),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String sourceUrl;

  const NewsDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.sourceUrl,
  });

  // Launch directly instead of gating on canLaunchUrl: with Android 11+
  // package visibility it reports false even when a browser exists.
  Future<void> _openSourceUrl(BuildContext context) async {
    try {
      final launched = await launchUrl(
        Uri.parse(sourceUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw Exception('no handler');
    } catch (e) {
      debugPrint("ERROR: Could not open $sourceUrl: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link in browser')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (sourceUrl.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              tooltip: 'Read Original on Web',
              onPressed: () => _openSourceUrl(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            if (date.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                date,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
            if (sourceUrl.isNotEmpty) ...[
              const SizedBox(height: 32),
              Center(
                child: FilledButton.icon(
                  onPressed: () => _openSourceUrl(context),
                  icon: const Icon(Icons.language),
                  label: const Text('Read Original on Web'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}
