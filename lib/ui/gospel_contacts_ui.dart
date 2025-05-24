import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'This is a placeholder for the Contacts page. Add your contact list or management features here.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add functionality to add a contact or perform another action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add contact functionality not implemented yet')),
                );
              },
              child: const Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }
}