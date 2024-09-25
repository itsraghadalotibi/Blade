import 'package:blade_app/features/newPost/screens/backgroundPost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../blocs/bloc/post_bloc.dart';
import '../blocs/bloc/post_event.dart';
import '../blocs/bloc/post_state.dart';
import 'chipTags.dart';

final uuid = Uuid();
final _formKeyStep1 = GlobalKey<FormState>();  // Key for Step 1
final _formKeyStep2 = GlobalKey<FormState>();  // Key for Step 2

class NumberStepper extends StatefulWidget {
  final ValueChanged<int> onNumberChanged;  // Callback for number change

  NumberStepper({required this.onNumberChanged});

  @override
  _NumberStepperState createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  int _numberOfMembers = 1; // Initial value is now 1
  bool _showMaxMessage = false; // Flag to show message when user tries to go beyond 10

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft, // Align the entire widget to the left
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min, // Make the Row take the minimum space required
            children: <Widget>[
              // Decrement Button
              IconButton(
                icon: const Icon(Icons.remove, size: 20, color: Colors.white),  // Reduced icon size
                onPressed: () {
                  setState(() {
                    if (_numberOfMembers > 1) {  // Prevent going below 1
                      _numberOfMembers--;
                      _showMaxMessage = false;  // Hide the max message if decrementing
                    }
                    widget.onNumberChanged(_numberOfMembers); // Notify parent
                  });
                },
              ),
              
              // Display the current number of members
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),  // Adjust padding to move the number left
                child: Text(
                  '$_numberOfMembers',
                  style: const TextStyle(fontSize: 16.0, color: Colors.white),  // Reduced font size
                ),
              ),
              
              // Increment Button
              IconButton(
                icon: const Icon(Icons.add, size: 20),  // Reduced icon size
                color: (_numberOfMembers < 10) ? Colors.white : Colors.grey, // Change color to silver if at max
                onPressed: (_numberOfMembers < 10) // Disable the button if at max
                    ? () {
                        setState(() {
                          _numberOfMembers++;
                          widget.onNumberChanged(_numberOfMembers); // Notify parent
                        });
                      }
                    : () {
                        setState(() {
                          _showMaxMessage = true; // Show the max message when user attempts to exceed 10
                        });
                      },
              ),
            ],
          ),
          // Notify user when the max value (10) is reached
          if (_showMaxMessage)
            const Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Text(
                'Maximum number of members is 10',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}


class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final _ideanameController = TextEditingController();
  final _ideadescriptionController = TextEditingController();
  final _numberController = TextEditingController(text: '1'); // Initialize with default value "1"
  final AnnouncementRepository _ideaRepository = AnnouncementRepository(firestore: FirebaseFirestore.instance); // Use IdeaRepository

  String? _skillsError; // To store error message
  List<String> topSkills = [];  // To store the top 10 skills
  bool _isSubmitted = false;  // Flag to track when the next button is pressed
  List<String> initialTags = [];  
  List<String> tags = [];
  List<String> options = [];  

  @override
  void initState() {
    super.initState();
    _numberController.text = '1'; // Set the default value to "1"
    fetchSkills(); // Fetch the skills when the widget initializes
  }

  Future<void> fetchSkills() async {
    try {
      final skillsSnapshot = await FirebaseFirestore.instance.collection('skills').get();
      final skills = skillsSnapshot.docs.map((doc) => doc['name'] as String).toList();
      
      setState(() {
        options = skills;  // Store all fetched skills for the search functionality
        topSkills = skills.take(6).toList();  // Take the first 10 skills for initial display
      });
    } catch (e) {
      print('Error fetching skills: $e');
    }
  }

  void _submitIdea() async {
    if (_ideanameController.text.isEmpty || _ideadescriptionController.text.isEmpty || _numberController.text.isEmpty) {
      // Show error or validation message
      return;
    }
  String creatorId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Create a new Idea object
    Idea newIdea = Idea(
      title: _ideanameController.text,
      description: _ideadescriptionController.text,
      maxMembers: int.parse(_numberController.text),
      members: [creatorId],  // Initially empty, will be updated later
      skills: tags,  // Pass the selected skills
    );

    // Save the new Idea to Firestore
  try {
    // Save the new Idea to Firestore
    await _ideaRepository.createIdea(newIdea, creatorId);

    // Navigate to the backgroundScreen with success message
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => backgroundScreen(isSuccess: true),
      ),
    );
  } catch (e) {
    // Handle any errors that occur during submission
    print('Error creating idea: $e');
  }

    // Show confirmation or navigate back
  }

  void onStepContinue(BuildContext context, int currentStep) {
    setState(() {
      _isSubmitted = true;  // Set to true when the Next button is pressed
    });

    if (currentStep == 0 && !_formKeyStep1.currentState!.validate()) {
      return;  // Stop if validation fails for step 1
    }

    // Step 2 Validation: Number of Members
    if (currentStep == 1) {
      final number = int.tryParse(_numberController.text) ?? 1; // Ensure the default value is 1
      if (number < 1) {
        setState(() {
          _isSubmitted = true;
        });
        return;
      }
    }

    // Step 3 Validation: Skills
    if (currentStep == 2) {
      setState(() {
        if (tags.isEmpty) {  // Check if no skill has been selected
          _skillsError = 'Please select at least one skill';
        } else {
          _skillsError = null;  // Clear error if a skill is selected
        }
      });

      if (tags.isEmpty) {
        return;  // Stop if validation fails
      }
    }

    final isLastStep = currentStep == getSteps().length - 1;
    if (isLastStep) {
      _submitIdea();  // Submit the form and save the idea
    } else {
      context.read<PostBloc>().add(NextStep());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
    create: (context) => PostBloc(announcementRepository: AnnouncementRepository(firestore: FirebaseFirestore.instance)),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              if (state is SubmissionState) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    ],
                  ),
                );
              }

              if (state is PostStepState) {
                return Theme(
                  data: ThemeData(
                    primaryColor: const Color(0xFFFD5336),
                    colorScheme: const ColorScheme.light(primary: Color(0xFFFD5336)),
                  ),
                  child: Stepper(
                    steps: getSteps(),
                    currentStep: state.currentStep,
                    onStepCancel: () {
                      if (state.currentStep > 0) {
                        context.read<PostBloc>().add(PreviousStep());
                      }
                    },
                    onStepContinue: () {
                      final currentState = context.read<PostBloc>().state;
                      if (currentState is PostStepState) {
                        onStepContinue(context, currentState.currentStep);
                      }
                    },
                    controlsBuilder: (BuildContext context, ControlsDetails details) {
                      final isLastStep = details.currentStep == getSteps().length - 1;
                      return Row(
                        children: [
                          if (details.currentStep != 0)
                            TextButton(
                              onPressed: details.onStepCancel,
                              style: TextButton.styleFrom(foregroundColor: Colors.grey),
                              child: const Text('Back'),
                            ),
                          // Conditionally show "Next" or "Submit" button
                          TextButton(
                            onPressed: isLastStep
                                ? () {
                                    // Submit action on the last step
                                    _submitIdea();
                                  }
                                : details.onStepContinue,  // Next action on previous steps
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFD5336)),
                            child: Text(isLastStep ? 'Submit' : 'Next'),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }

              return Container();
            },
          ),
        ),
      ),
    );
  }

  List<Step> getSteps() {
    return <Step>[
      Step(
        title: const Text('Project', style: TextStyle(color: Colors.white)),
        content: Form(
          key: _formKeyStep1,
          child: Column(
            children: [
              const SizedBox(height: 5),
              TextFormField(
                controller: _ideanameController,
                style: const TextStyle(color: Colors.white),
                autovalidateMode: AutovalidateMode.onUserInteraction,  
                decoration: InputDecoration(
                  hintText: 'Project Name',
                  hintStyle: const TextStyle(
                    color: Colors.grey, 
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: const BorderSide(width: 1, color: TColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: const BorderSide(width: 1, color: TColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: const BorderSide(width: 2, color: TColors.borderPrimary),
                  ),
                ),
                validator: (value) {
                  if (_isSubmitted && (value == null || value.isEmpty)) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_isSubmitted) {
                    _formKeyStep1.currentState!.validate();
                  }
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                maxLength: 250,
                controller: _ideadescriptionController,
                style: const TextStyle(color: Colors.white), 
                autovalidateMode: AutovalidateMode.onUserInteraction, 
                decoration: InputDecoration(
                  hintText: 'Describe your idea',
                  hintStyle: const TextStyle(
                    color: Colors.grey, 
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: const BorderSide(width: 1, color: TColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: const BorderSide(width: 1, color: TColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: const BorderSide(width: 2, color: TColors.borderPrimary),
                  ),
                ),
                validator: (value) {
                  if (_isSubmitted && (value == null || value.isEmpty)) {
                    return 'Please describe your idea';
                  } else if (value != null && value.length < 50) {
                    return 'At least 50 characters required';
                  }
                  return null;
                },
                buildCounter: (
                  BuildContext context, {
                  required int currentLength,
                  required bool isFocused,
                  required int? maxLength,
                }) {
                  return Text(
                    '$currentLength / $maxLength',
                    style: TextStyle(color: Colors.grey[300], fontSize: 12),
                  );
                },
              ),
            ],
          ),
        ),
        isActive: true,
        state: StepState.indexed,
      ),
      Step(
        title: const Text('Members', style: TextStyle(color: Colors.white)),
        content: Column(
          children: [
            const SizedBox(height: 5),
            NumberStepper(
              onNumberChanged: (newNumber) {
                setState(() {
                  _numberController.text = newNumber.toString(); 
                });
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
        isActive: true,
        state: StepState.indexed,
      ),
      Step(
        title: const Text('Skills', style: TextStyle(color: Colors.white)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return options.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selectedTag) {
                setState(() {
                  if (!tags.contains(selectedTag)) {
                    tags.add(selectedTag);
                  }
                  if (!topSkills.contains(selectedTag)) {
                    topSkills.add(selectedTag);
                  }
                });
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search and add more skills',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: TColors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: TColors.borderPrimary, width: 2),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.grey[850],
                    elevation: 4,
                    child: Container(
                      width: 325,
                      height: 220,
                      child: ListView.builder(
                        padding: EdgeInsets.all(1.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(
                                option,
                                style: const TextStyle(color: Colors.white),
                              ),
                              tileColor: Colors.grey[800],
                              hoverColor: Colors.blueGrey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: topSkills.map((skill) {
                return FilterChip(
                  label: Text(skill, style: const TextStyle(color: Colors.white)),
                  selected: tags.contains(skill),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        tags.add(skill);
                      } else {
                        tags.remove(skill);
                      }
                    });
                  },
                  backgroundColor: Colors.grey[700],
                  selectedColor: Color(0xFFFD5336),
                  showCheckmark: true,
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_skillsError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _skillsError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        isActive: true,
        state: StepState.indexed,
      ),
    ];
  }
}
