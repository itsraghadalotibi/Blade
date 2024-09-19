import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';
import 'blocs/bloc/post_event.dart';
import 'blocs/bloc/post_state.dart';
import 'blocs/bloc/post_bloc.dart';
import 'src/repositories/firebase_post_repo.dart';

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

  // List of tags for the ChipsChoice widget
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc( postRepository: FirebasePostRepository(),  // Provide your repository implementation
),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10), // This adds padding around all sides
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              if (state is SubmissionState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const Text('Announcement Completed'),
                    Container(
                              width: 200,
                              height: 200,
                              child: Lottie.asset('assets/lottie/sent.json'),
                               // Lottie animation for completion
                            ), 
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.pop(context);
                      //   },
                      //   child: const Text('OK'),
                      // )
                    ],
                  ),
                );
              }

               if (state is PostStepState) {
               return Theme(
                  data: ThemeData(
                    primaryColor: const Color.fromARGB(255, 255, 85, 7), // Set primary color for stepper
                    colorScheme: const ColorScheme.light(
                      primary:  Color.fromARGB(255, 255, 85, 7), // Active step color
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
                      final currentStep = currentState.currentStep;

                      // Validate the current step's form
                      if (currentStep == 0) {
                        if (!_formKeyStep1.currentState!.validate()) {
                          return;  // If validation fails, stop here and show the error
                        }
                      } else if (currentStep == 1) {
                        if (!_formKeyStep2.currentState!.validate()) {
                          return;  // If validation fails, stop here and show the error
                        }
                      }

                      final isLastStep = currentStep == getSteps().length - 1;

                      // If it's the last step, submit the form
                      if (isLastStep) {
                        context.read<PostBloc>().add(SubmitStep(
                          id: uuid.v4(),
                          ideaName: _ideanameController.text,
                          ideaDescription: _ideadescriptionController.text,
                          number: _numberController.text,
                          tags: tags,
                          userId: 'current-user-id',  // Replace with actual user ID
                        ));
                      } else {
                        // Proceed to the next step
                        context.read<PostBloc>().add(NextStep());
                      }
                    }
                  },
                    // Custom icons based on step state
                    controlsBuilder: (BuildContext context, ControlsDetails details) {
                      return Row(
                        children: [
                          TextButton(
                            onPressed: details.onStepContinue,
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

  // Customize the step states, include custom icons
List<Step> getSteps() {
  return <Step>[
    Step(
      title: const Text('Project', style: TextStyle(color: Colors.white),  // Set text color to white
      ),
      content: Form(
        key: _formKeyStep1,  // Associate this form with the step
        child: Column(
          children: [
            const SizedBox(height: 5),
            TextFormField(
              controller: _ideanameController,
              style: const TextStyle(color: Colors.white),  // Set text color to white
              decoration: InputDecoration(
                hintText: 'Project Name',
                hintStyle: const TextStyle(color: Colors.grey),  // Adjusted color for hint text
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
                hintStyle: const TextStyle(color: Colors.grey),
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
                }
                return null;
              },
            ),
          ],
        ),
      ),
      isActive: true,
      state: StepState.indexed,  // Change state based on the current state of the step
    ),
    Step(
      title: const Text('Members', style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKeyStep2,  // Associate this form with the step
        child: Column(
          children: [
            const SizedBox(height: 5),
            TextFormField(
              controller: _numberController,
              style: const TextStyle(color: Colors.white),  
              decoration: InputDecoration(
                hintText: 'Needed members',
                hintStyle: const TextStyle(color: Colors.grey),  // Adjusted color for hint text
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
                return null;
              },
            ),
          ],
        ),
      ),
      isActive: true,
      state: StepState.indexed,  // Track step state
    ),
    Step(
      title: const Text('Skills', style: TextStyle(color: Colors.white)),
      content: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Wrap(
          spacing: 8.0, // Space between chips
          runSpacing: 8.0, // Space between lines of chips
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: tags.contains(option),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    tags.add(option);
                  } else {
                    tags.remove(option);
                  }
                });
              },
              selectedColor: const Color.fromARGB(255, 255, 85, 7),
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
      ),
      isActive: true,
      state: StepState.indexed,  // Track step state
    ),
  ];
}
}