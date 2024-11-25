import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ai_todo/src/ai_todo_repository.dart';
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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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

  Future<void> _updateProjectStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Update the project status in Firestore
      await widget.repository.updateIdeaStatus(widget.idea.id!, _selectedStatus!);
      print('Project status updated to $_selectedStatus');

      // Step 2: If the status is changed to "ongoing", generate and save the to-do list
      if (_selectedStatus == 'ongoing') {
        try {
          final aiTodoRepository = AiTodoRepository();
          final steps = await aiTodoRepository.generateToDoList(widget.idea.id!, widget.idea.description);

          // Log steps to console (for debugging)
          for (var step in steps) {
            print('Generated ToDo Step: ${step.title}, ${step.description}');
          }
        } catch (aiError) {
          print('Error generating to-do list: $aiError');
          throw Exception('Failed to generate AI to-do list');
        }
      }

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Project status changed successfully!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true); // Navigate back and indicate success
    } catch (e) {
      // Step 3: Handle errors for both status update and AI generation
      print('Error updating project status or generating AI list: $e');
      setState(() {
        _errorMessage = 'Failed to update project status. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to update project status. Please try again.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final availableStatusOptions = _getAvailableStatusOptions(widget.idea.status);

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
                        color:
                            isDarkMode ? Colors.white70 : Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    dropdownColor:
                        isDarkMode ? Colors.grey[800] : Colors.white,
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
                      onPressed: _selectedStatus != widget.idea.status && !_isLoading
                          ? _updateProjectStatus
                          : null, // Disable button if no change or loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                        side: const BorderSide(color: Colors.green),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                          : const Text('Save Status'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
