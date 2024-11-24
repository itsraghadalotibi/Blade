import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  final String supporterId;

  const DashboardScreen({Key? key, required this.supporterId})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalRequests = 0;
  int acceptedRequests = 0;
  int pendingRequests = 0;
  int rejectedRequests = 0;
  int expiredRequests = 0;
  int cancelledRequests = 0;

  Map<String, double> requestTypesData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequestsData();
  }

  Future<void> _fetchRequestsData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('investment_requests')
          .where('supporterId', isEqualTo: widget.supporterId)
          .get();

      setState(() {
        totalRequests = querySnapshot.docs.length;
        acceptedRequests = querySnapshot.docs
            .where((doc) => doc['status'] == 'Accepted')
            .length;
        pendingRequests = querySnapshot.docs
            .where((doc) => doc['status'] == 'Pending')
            .length;
        rejectedRequests = querySnapshot.docs
            .where((doc) => doc['status'] == 'Rejected')
            .length;
        expiredRequests = querySnapshot.docs
            .where((doc) => doc['status'] == 'Expired')
            .length;
        cancelledRequests = querySnapshot.docs
            .where((doc) => doc['status'] == 'Cancelled')
            .length;

        // Group by request type (offer field)
        requestTypesData = {};
        for (var doc in querySnapshot.docs) {
          final type = doc['offer'] ?? 'Unknown';
          if (requestTypesData.containsKey(type)) {
            requestTypesData[type] = requestTypesData[type]! + 1;
          } else {
            requestTypesData[type] = 1;
          }
        }

        isLoading = false; // Set loading to false after fetching data
      });
    } catch (e) {
      print('Error fetching requests: $e');
      setState(() {
        isLoading = false; // Ensure loading is set to false even on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('Total', totalRequests, Colors.blue),
                      _buildStatCard(
                          'Accepted', acceptedRequests, Colors.green),
                      _buildStatCard('Pending', pendingRequests, Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('Rejected', rejectedRequests, Colors.red),
                      _buildStatCard('Expired', expiredRequests, Colors.grey),
                      _buildStatCard(
                          'Cancelled', cancelledRequests, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Request Type Breakdown',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: requestTypesData.isEmpty
                        ? const Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : PieChart(
                            dataMap: requestTypesData,
                            animationDuration:
                                const Duration(milliseconds: 800),
                            chartType: ChartType.ring,
                            chartRadius:
                                MediaQuery.of(context).size.width / 2.5,
                            colorList: [
                              Colors.blue,
                              Colors.green,
                              Colors.orange,
                              Colors.red,
                              Colors.purple,
                              Colors.teal,
                            ],
                            centerText: "Types",
                            legendOptions: const LegendOptions(
                              showLegendsInRow: false,
                              legendPosition: LegendPosition.bottom,
                              showLegends: true,
                              legendShape: BoxShape.circle,
                              legendTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            chartValuesOptions: const ChartValuesOptions(
                              showChartValuesInPercentage: true,
                              showChartValuesOutside: false,
                              decimalPlaces: 1,
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
