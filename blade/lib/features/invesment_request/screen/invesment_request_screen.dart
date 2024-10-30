import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InvestmentRequestScreen extends StatefulWidget {
  final String ideaId;

  const InvestmentRequestScreen({Key? key, required this.ideaId}) : super(key: key);

  @override
  _InvestmentRequestScreenState createState() => _InvestmentRequestScreenState();
}

class _InvestmentRequestScreenState extends State<InvestmentRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('invesment_request')
            .where('ideaId', isEqualTo: widget.ideaId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading requests.'));
          }

          final requests = snapshot.data?.docs ?? [];
          if (requests.isEmpty) {
            return const Center(
              child: Text('No investment requests found for this idea.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final String name = request['name'] ?? 'Unknown Investor';
              final String price = request['price'] ?? '0';
              final String reasonForInterest = request['reasonForInterest'] ?? 'N/A';
              final String contactInfo = request['contactInfo'] ?? 'N/A';
              final String status = request['status'] ?? 'pending';

              return InvestmentRequestCard(
                amount: price,
                supporterName: name,
                reasonForInterest: reasonForInterest,
                contactInfo: contactInfo,
                status: status,
                onAccept: () => _updateRequestStatus(request.id, 'accepted'),
                onReject: () => _showRejectionDialog(context, request.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status, {String? reason}) async {
    try {
      await FirebaseFirestore.instance.collection('invesment_request').doc(requestId).update({
        'status': status,
        if (reason != null) 'reason': reason,
      });

      // Show a green confirmation message with a check_circle icon for both accepted and rejected requests
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white), // Consistent check icon
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Request ${status == 'accepted' ? 'accepted' : 'rejected'} successfully.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showRejectionDialog(BuildContext context, String requestId) {
    final TextEditingController reasonController = TextEditingController();
    bool showError = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Reject Investment Request",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Rejection Reason',
                    ),
                  ),
                  if (showError)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please provide a reason.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close the dialog
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 2),
                TextButton(
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (reason.isNotEmpty) {
                      Navigator.of(dialogContext).pop(); // Close the dialog
                      _updateRequestStatus(requestId, 'rejected', reason: reason);
                    } else {
                      // Show error message under the text field
                      setState(() {
                        showError = true;
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(
                    "Reject",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class InvestmentRequestCard extends StatelessWidget {
  final String amount;
  final String supporterName;
  final String reasonForInterest;
  final String contactInfo;
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const InvestmentRequestCard({
    Key? key,
    required this.amount,
    required this.supporterName,
    required this.reasonForInterest,
    required this.contactInfo,
    required this.status,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'accepted':
          return Colors.lightGreen[100]!;
        case 'rejected':
          return Colors.red[100]!;
        default:
          return Colors.lightBlue[100]!;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Amount of Interest',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '\$$amount',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Center(child: CoinIconPainter()), // Custom coin icon
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Investment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Supporter Name', supporterName),
          _buildDetailRow('Reason for Interest', reasonForInterest),
          _buildDetailRow('Contact Information', 'Phone number: $contactInfo'),
          const SizedBox(height: 16),
          if (status == 'pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: onAccept,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                  child: const Text('Accept'),
                ),
              ],
            )
          else
            Text(
              status[0].toUpperCase() + status.substring(1),
              style: TextStyle(
                color: status == 'accepted' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class CoinIconPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 80,
      child: CustomPaint(
        painter: _CoinIconPainter(),
      ),
    );
  }
}

class _CoinIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final coinPaint = Paint()..color = Colors.orange[300]!;
    final dollarPaint = Paint()..color = Colors.blue;
    final arrowPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw coins
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 15, coinPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 15, coinPaint);

    // Draw dollar signs inside coins
    final textStyle = TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: '\$', style: textStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.25, size.height * 0.35));
    textPainter.paint(canvas, Offset(size.width * 0.65, size.height * 0.55));

    // Draw arrows
    final arrowPath1 = Path()
      ..moveTo(size.width * 0.3, size.height * 0.2)
      ..arcToPoint(
        Offset(size.width * 0.5, size.height * 0.4),
        radius: const Radius.circular(10),
      );
    final arrowPath2 = Path()
      ..moveTo(size.width * 0.7, size.height * 0.8)
      ..arcToPoint(
        Offset(size.width * 0.5, size.height * 0.6),
        radius: const Radius.circular(10),
      );

    canvas.drawPath(arrowPath1, arrowPaint);
    canvas.drawPath(arrowPath2, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




