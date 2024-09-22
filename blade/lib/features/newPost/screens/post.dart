import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../blocs/bloc/post_bloc.dart';
import '../blocs/bloc/post_event.dart';
import '../blocs/bloc/post_state.dart';
import '../src/repositories/firebase_post_repo.dart';
import 'chipTags.dart';

final uuid = Uuid();
final postId = uuid.v4(); // Generates a unique ID
final _formKeyStep1 = GlobalKey<FormState>();  // Key for Step 1
final _formKeyStep2 = GlobalKey<FormState>();  // Key for Step 2

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final _ideanameController = TextEditingController();
  final _ideadescriptionController = TextEditingController();
  final _numberController = TextEditingController();

  List<String> initialTags = [];  
  List<String> tags = [];
  List<String> options = [
    'React',
    'Frontend Developer',
    'Backend Developer',
    'UI/UX',
    'Mern Stack',
    'Flutter',
    'Web',
    'AI'
  ];  
  String? _skillsError; // To store error message

  void onStepContinue(BuildContext context, int currentStep) {
    if (currentStep == 0 && !_formKeyStep1.currentState!.validate()) {
      return;  // Validate Step 1 form
    } else if (currentStep == 1 && !_formKeyStep2.currentState!.validate()) {
      return;  // Validate Step 2 form
    }

    // Validate skills selection in Step 3
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

    // Proceed if there are no errors
    final isLastStep = currentStep == getSteps().length - 1;
    if (isLastStep) {
      context.read<PostBloc>().add(SubmitStep(
        id: uuid.v4(),
        ideaName: _ideanameController.text,
        ideaDescription: _ideadescriptionController.text,
        number: _numberController.text,
        tags: tags,  // Pass the selected tags
        userId: 'current-user-id',  // Replace with actual user ID
      ));
    } else {
      context.read<PostBloc>().add(NextStep());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(postRepository: FirebasePostRepository()),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              if (state is SubmissionState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: Lottie.asset('assets/lottie/sent.json'),
                      ), 
                    ],
                  ),
                );
              }

              if (state is PostStepState) {
                return Theme(
                  data: ThemeData(
                primaryColor: const Color(0xFFFD5336),
                    colorScheme: const ColorScheme.light(
                      primary:  Color(0xFFFD5336),
                    ),
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
                      return Row(
                        children: [
                          TextButton(
                            onPressed: details.onStepContinue,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFFD5336),  // Set the text color to #FD5336
                            ),
                            child: const Text('Next'),
                          ),
                          if (details.currentStep != 0)
                            TextButton(
                              onPressed: details.onStepCancel,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                              child: const Text('Back'),
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
                decoration: InputDecoration(
                  hintText: 'Project Name',
                      hintStyle: const TextStyle(
                        color: Colors.grey, 
                        fontSize: 13,  // Set the font size to be smaller
                        fontWeight: FontWeight.normal,  // Set the font weight to normal (not bold)
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                controller: _ideadescriptionController,
                style: const TextStyle(color: Colors.white), 
                decoration: InputDecoration(
                  hintText: 'Describe your idea',
                      hintStyle: const TextStyle(
                        color: Colors.grey, 
                        fontSize: 13,  // Set the font size to be smaller
                        fontWeight: FontWeight.normal,  // Set the font weight to normal (not bold)
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
                  if (value == null || value.isEmpty) {
                    return 'Please describe your idea';
                  } else if (value.length < 10) {
                    return 'Description must be at least 10 characters long';
                  } else if (value.length > 250) {
                    return 'Description cannot be more than 250 characters';
                  }
                  return null;
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
        content: Form(
          key: _formKeyStep2,
          child: Column(
            children: [
              const SizedBox(height: 5),
              TextFormField(
                controller: _numberController,
                style: const TextStyle(color: Colors.white),  
                decoration: InputDecoration(
                  hintText: 'Needed members',
                      hintStyle: const TextStyle(
                        color: Colors.grey, 
                        fontSize: 13,  // Set the font size to be smaller
                        fontWeight: FontWeight.normal,  // Set the font weight to normal (not bold)
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of needed members';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 1) {
                    return 'Please enter a valid number of members (minimum 1)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        isActive: true,
        state: StepState.indexed,
      ),
      Step(
        title: const Text('Skills', style: TextStyle(color: Colors.white)),
        content: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChipTag(
                initialTags: tags,
                options: options,
                onTagSelected: (tag, selected) {
                  setState(() {
                    if (selected) {
                      tags.add(tag);  // Add selected tag to 'tags'
                    } else {
                      tags.remove(tag);  // Remove deselected tag from 'tags'
                    }
                  });
                },
              ),
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
        ),
        isActive: true,
        state: StepState.indexed,
      ),
    ];
  }
}
