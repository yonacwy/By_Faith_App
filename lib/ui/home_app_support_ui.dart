import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeAppSupportUi extends StatelessWidget {
  const HomeAppSupportUi({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Discord Link
              ListTile(
                leading: const Icon(FontAwesomeIcons.discord, color: Colors.blue),
                title: const Text('Join our Discord'),
                subtitle: const Text('https://discord.gg/KXg35XGFtK'),
                onTap: () => _launchUrl('https://discord.gg/KXg35XGFtK'),
              ),
              // Github Link
              ListTile(
                leading: const Icon(FontAwesomeIcons.github, color: Colors.black),
                title: const Text('View on GitHub'),
                subtitle: const Text('https://github.com/yonacwy/by_faith_app'),
                onTap: () => _launchUrl('https://github.com/yonacwy/by_faith_app'),
              ),
              // Email Link
              ListTile(
                leading: const Icon(Icons.email, color: Colors.red),
                title: const Text('Email Support'),
                subtitle: const Text('barry.b.smith@gmail.com'),
                onTap: () => _launchUrl('mailto:barry.b.smith@gmail.com'),
              ),
              const SizedBox(height: 32),
              const Text(
                'Thank you for your support!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}