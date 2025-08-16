import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialFollowPage extends StatefulWidget {
  const SocialFollowPage({super.key});

  @override
  _SocialFollowPageState createState() => _SocialFollowPageState();
}

class _SocialFollowPageState extends State<SocialFollowPage> {
  final Map<String, bool> _followed = {
    'Facebook': false,
    'Instagram': false,
    'YouTube': false,
    'WhatsApp': false,
  };

  int get doneCount => _followed.values.where((v) => v).length;

  Future<void> openAndMarkFollow(String platform, String url) async {
    final uri = Uri.parse(url);

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (launched) {
      setState(() {
        _followed[platform] = true;
      });

      // Optional: confirmation after opening
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marked $platform as followed')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $platform')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          children: [
            // Header
            Image.asset('assets/image/photo_2025-07-09_13-34-29.jpg', width: 100, height: 100),
            const SizedBox(height: 16),
            const Text(
              'Welcome to\nPulsePost!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              'To get started, please follow us on the platforms below. '
                  'This helps you stay informed and get priority in tasks.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Progress
            Row(
              children: [
                const Text('Progress'),
                const Spacer(),
                Text('$doneCount/4'),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: doneCount / 4,
              color: Colors.blueAccent,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),

            // Platform cards
            _platformCard(
              icon: FontAwesomeIcons.facebook,
              iconColor: Colors.blue[800]!,
              title: 'Facebook',
              subtitle: 'Follow us on Facebook',
              done: _followed['Facebook']!,
              onTap: () => openAndMarkFollow('Facebook', 'https://www.facebook.com/'),
            ),
            _platformCard(
              icon: FontAwesomeIcons.instagram,
              iconColor: Colors.purple,
              title: 'Instagram',
              subtitle: 'Follow us on Instagram',
              done: _followed['Instagram']!,
              onTap: () => openAndMarkFollow('Instagram', 'https://www.instagram.com/'),
            ),
            _platformCard(
              icon: FontAwesomeIcons.youtube,
              iconColor: Colors.red,
              title: 'YouTube',
              subtitle: 'Subscribe to our YouTube',
              done: _followed['YouTube']!,
              onTap: () => openAndMarkFollow('YouTube', 'https://www.youtube.com/'),
            ),
            _platformCard(
              icon: FontAwesomeIcons.whatsapp,
              iconColor: Colors.green,
              title: 'WhatsApp',
              subtitle: 'Join our WhatsApp Broadcast',
              done: _followed['WhatsApp']!,
              onTap: () => openAndMarkFollow('WhatsApp', 'https://wa.me/919999999999'),
            ),

            const SizedBox(height: 16),
            const Text('Please follow all platforms above to unlock access'),
            const SizedBox(height: 12),

            // Final Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: doneCount == 4
                    ? () {
                  Navigator.pushNamed(context, '/home');
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: doneCount == 4 ? Colors.blueAccent : Colors.grey,
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Complete all follows to continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _platformCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool done,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            FaIcon(icon, size: 32, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            done
                ? ElevatedButton(onPressed: null, child: const Text("I've Followed"))
                : OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.person_add),
              label: const Text('Follow'),
            ),
          ],
        ),
      ),
    );
  }
}
