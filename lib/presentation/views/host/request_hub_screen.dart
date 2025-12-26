import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class RequestHubScreen extends StatelessWidget {
  const RequestHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch pending requests from backend
    final pendingRequests = <Map<String, dynamic>>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Requests'),
      ),
      body: pendingRequests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.request_quote, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final request = pendingRequests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Request #${request['id']}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Chip(
                              label: const Text('PENDING'),
                              backgroundColor: Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Car: ${request['car_name']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Renter: ${request['renter_name']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dates: ${request['start_date']} - ${request['end_date']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total: \$${request['total_price']}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // TODO: Reject request
                                },
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomButton(
                                text: 'Accept',
                                onPressed: () {
                                  // TODO: Accept request
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}



