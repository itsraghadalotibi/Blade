import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/constants/colors.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';

class ChangeProjectStatusScreen extends StatefulWidget {
  final Idea idea;
  final AnnouncementRepository repository;

  const ChangeProjectStatusScreen({
    Key? key,
    required this.idea,
    required this.repository,
  }) : super(key: key);

  @override
  _ChangeProjectStatusScreenState createState() =>
      _ChangeProjectStatusScreenState();
}

class _ChangeProjectStatusScreenState extends State<ChangeProjectStatusScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Do not set _selectedStatus to the current status if it's not in available options
    // Instead, set it to null or the first available option
    final availableOptions = _getAvailableStatusOptions(widget.idea.status);
    if (availableOptions.isNotEmpty) {
      _selectedStatus = availableOptions[0];
    } else {
      _selectedStatus = null;
    }
  }

  List<String> _getAvailableStatusOptions(String currentStatus) {
    switch (currentStatus) {
      case 'open':
        return ['ongoing', 'completed'];
      case 'ongoing':
        return ['completed'];
      default:
        return [];
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'ongoing':
        return Colors.blue[900]!;
      case 'completed':
        return Colors.grey[800]!;
      default:
        return Colors.green[900]!;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ongoing':
        return Colors.blue[100]!;
      case 'completed':
        return Colors.grey[300]!;
      default:
        return Colors.green[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final availableStatusOptions =
        _getAvailableStatusOptions(widget.idea.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Project Status'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: availableStatusOptions.isEmpty
            ? const Center(
                child: Text(
                  'The project status is already completed and cannot be changed.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Current Status: ${widget.idea.status[0].toUpperCase() + widget.idea.status.substring(1)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    dropdownColor:
                        isDarkMode ? TColors.darkerGrey : TColors.lightGrey,
                    decoration: InputDecoration(
                      labelText: 'Select New Status',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    items: availableStatusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a status';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note: You will not be able to change back to the previous status.',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedStatus != widget.idea.status
                          ? () {
                              // Dispatch event to change status
                              context.read<ProjectBloc>().add(
                                    UpdateProjectStatus(
                                        widget.idea.id!, _selectedStatus!),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: TColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Icon(
                                            CupertinoIcons
                                                .check_mark_circled_solid,
                                            color: Colors
                                                .white), // Change icon and color as needed
                                        const SizedBox(
                                            width:
                                                8), // Space between icon and text
                                        const Expanded(
                                          child: Text(
                                            'Project status changed Successfully!',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    showCloseIcon: true),
                              );
                              Navigator.pop(context, true);
                            }
                          : null, // Disable button if no change
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                        side: const BorderSide(color: Colors.green),
                      ),
                      child: const Text('Save Status'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
