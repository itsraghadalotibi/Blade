import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/states_bloc.dart';
import '../bloc/states_event.dart';
import '../bloc/states_page_state.dart';
import '../../../utils/constants/colors.dart';

class StatesPage extends StatelessWidget {
  const StatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return BlocProvider(
      create: (context) => StatesBloc(FirebaseFirestore.instance)
        ..add(LoadStates(FirebaseAuth.instance.currentUser!.uid)),
      child: Scaffold(
        backgroundColor: isDarkMode ? TColors.dark : TColors.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Idea Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? TColors.textWhite : TColors.textPrimary,
                ),
          ),
        ),
        body: BlocBuilder<StatesBloc, StatesPageState>(
          builder: (context, state) {
            if (state is StatesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StatesError) {
              return Center(
                child: Text(
                  'Error: ${state.error}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              );
            } else if (state is StatesLoaded) {
              if (state.joinRequests.isEmpty) {
                return const Center(
                  child: Text(
                    'No ideas found.',
                    style: TextStyle(color: TColors.textSecondary),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.05,
                ),
                itemCount: state.joinRequests.length,
                itemBuilder: (context, index) {
                  final request = state.joinRequests[index];
                  final status = request['status'];
                  final timestamp = request['timestamp']; // Request time

                  IconData statusIcon;
                  Color statusColor;
                  String statusMessage;

                  if (status == 'accepted') {
                    statusIcon = Icons.check_circle;
                    statusColor = Colors.green;
                    statusMessage = 'Accepted';
                  } else if (status == 'rejected') {
                    statusIcon = Icons.cancel;
                    statusColor = Colors.red;
                    statusMessage = 'Rejected';
                  } else {
                    statusIcon = Icons.hourglass_top;
                    statusColor = Colors.amber;
                    statusMessage = 'Pending';
                  }

                  return GestureDetector(
                    onTap: () {
                      // Implement specific action on tap if needed.
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? TColors.container
                              : TColors.container,
                          borderRadius: BorderRadius.circular(23),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left: Idea Title and Timestamp
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request['ideaTitle'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: screenWidth *
                                            0.05 *
                                            textScaleFactor,
                                        fontWeight: FontWeight.w600,
                                        color: TColors.textWhite, // White title text
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Requested On: $timestamp',
                                      style: TextStyle(
                                        fontSize: screenWidth *
                                            0.035 *
                                            textScaleFactor,
                                        color: TColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Right: Status Icon and Message
                              Row(
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: statusColor,
                                    size: screenWidth * 0.08,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    statusMessage,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: screenWidth *
                                          0.04 *
                                          textScaleFactor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}














