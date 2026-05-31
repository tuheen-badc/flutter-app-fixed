import 'package:flutter/material.dart';

import 'location_selector.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search (No Validation)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Search keyword',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Filter by Location (Optional)'),
            const SizedBox(height: 8),
            LocationSelector(
              // No validation - these are optional filters
              enableValidation: false,
              showUpazilla: true,
              showUnion: true,
              onSelectionChanged: (selection) {
                print(
                  'Filter by: ${selection.division?.name} - ${selection.district?.name}',
                );
                // Perform search with location filter
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('Searching...');
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Search'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
