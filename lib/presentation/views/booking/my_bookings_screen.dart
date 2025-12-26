import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as error_widget;

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().getMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: bookingProvider.isLoading && bookingProvider.bookings.isEmpty
          ? const LoadingIndicator()
          : bookingProvider.errorMessage != null && bookingProvider.bookings.isEmpty
              ? error_widget.ErrorDisplayWidget(
                  message: bookingProvider.errorMessage!,
                  onRetry: () {
                    bookingProvider.getMyBookings();
                  },
                )
              : bookingProvider.bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No bookings yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await bookingProvider.getMyBookings();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookingProvider.bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookingProvider.bookings[index];
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
                                        'Booking #${booking.id}',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      Chip(
                                        label: Text(booking.status.toUpperCase()),
                                        backgroundColor: _getStatusColor(booking.status),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    'Dates',
                                    '${DateFormat('MMM dd').format(booking.startDate)} - ${DateFormat('MMM dd, yyyy').format(booking.endDate)}',
                                  ),
                                  _buildInfoRow(
                                    'Duration',
                                    '${booking.durationInDays} days',
                                  ),
                                  _buildInfoRow(
                                    'Total Price',
                                    '\$${booking.totalPrice.toStringAsFixed(2)}',
                                  ),
                                  _buildInfoRow(
                                    'Security Deposit',
                                    '\$${booking.securityDeposit.toStringAsFixed(2)}',
                                  ),
                                  _buildInfoRow(
                                    'Payment Status',
                                    booking.paymentStatus.toUpperCase(),
                                  ),
                                  if (booking.status == 'pending' || booking.status == 'active') ...[
                                    const Divider(height: 32),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              _showCancelDialog(context, booking.id);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCancelDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<BookingProvider>().cancelBooking(bookingId);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}



