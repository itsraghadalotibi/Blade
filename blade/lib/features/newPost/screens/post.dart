import 'package:blade_app/features/newPost/screens/backgroundPost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../blocs/bloc/post_bloc.dart';
import '../blocs/bloc/post_event.dart';
import '../blocs/bloc/post_state.dart';

final uuid = Uuid();
final _formKeyStep1 = GlobalKey<FormState>();
final _formKeyStep2 = GlobalKey<FormState>();

class NumberStepper extends StatefulWidget {
  final ValueChanged<int> onNumberChanged;

  NumberStepper({required this.onNumberChanged});

  @override
  _NumberStepperState createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  int _numberOfMembers = 1;
  bool _showMaxMessage = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.remove,
                  size: 20,
                  color: isDarkMode
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : const Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () {
                  setState(() {
                    if (_numberOfMembers > 1) {
                      _numberOfMembers--;
                      _showMaxMessage = false;
                    }
                    widget.onNumberChanged(_numberOfMembers);
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  '$_numberOfMembers',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  size: 20,
                  color: (_numberOfMembers < 20)
                      ? (isDarkMode
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 0, 0, 0))
                      : Colors.grey,
                ),
                onPressed: (_numberOfMembers < 20)
                    ? () {
                        setState(() {
                          _numberOfMembers++;
                          _showMaxMessage = false;
                          widget.onNumberChanged(_numberOfMembers);
                        });
                      }
                    : () {
                        setState(() {
                          _showMaxMessage = true;
                        });
                      },
              ),
            ],
          ),
          if (_showMaxMessage)
            const Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Text(
                'Maximum number of members is 20',
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
  final _numberController = TextEditingController(text: '1');
  final AnnouncementRepository _ideaRepository = AnnouncementRepository(
    firestore: FirebaseFirestore.instance,
  );
  final FocusNode _projectNameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final GlobalKey<FormState> _projectNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _descriptionFormKey = GlobalKey<FormState>();

  String? _skillsError;
  Color _messageColor = Colors.grey;
  bool _isSubmitted = false;
  List<String> topSkills = [];
  List<String> tags = [];
  List<String> options = [];

  @override
  void initState() {
    super.initState();
    _numberController.text = '1';
    fetchSkills();

    _projectNameFocusNode.addListener(() {
      if (!_projectNameFocusNode.hasFocus) {
        _projectNameFormKey.currentState!.validate();
      }
    });

    _descriptionFocusNode.addListener(() {
      if (!_descriptionFocusNode.hasFocus) {
        _descriptionFormKey.currentState!.validate();
      }
    });
  }

  @override
  void dispose() {
    _projectNameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> fetchSkills() async {
    try {
      final skillsSnapshot = await FirebaseFirestore.instance.collection('skills').get();
      final skills = skillsSnapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        options = skills;
        topSkills = skills.take(6).toList();
      });
    } catch (e) {
      print('Error fetching skills: $e');
    }
  }

  void _submitIdea() async {
    if (_ideanameController.text.isEmpty ||
        _ideadescriptionController.text.isEmpty ||
        _numberController.text.isEmpty ||
        tags.isEmpty) {
      setState(() {
        _skillsError = tags.isEmpty ? 'select at least one skill*' : null;
        _messageColor = tags.isEmpty ? Colors.red : Colors.grey;
      });
      return;
    }

    String creatorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Idea newIdea = Idea(
      title: _ideanameController.text,
      description: _ideadescriptionController.text,
      maxMembers: int.parse(_numberController.text),
      members: [creatorId],
      skills: tags,
    );

    try {
      await _ideaRepository.createIdea(newIdea, creatorId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => backgroundScreen(isSuccess: true)),
      );
    } catch (e) {
      print('Error creating idea: $e');
    }
  }

  void onStepContinue(BuildContext context, int currentStep) {
    setState(() {
      _isSubmitted = true;
    });

    if (currentStep == 0 &&
        (!_projectNameFormKey.currentState!.validate() ||
            !_descriptionFormKey.currentState!.validate())) {
      return;
    }

    if (currentStep == 1) {
      final number = int.tryParse(_numberController.text) ?? 1;
      if (number < 1) {
        return;
      }
    }

    if (currentStep == 2) {
      setState(() {
        if (tags.isEmpty) {
          _skillsError = 'Please select at least one skill';
          _messageColor = Colors.red;
        } else {
          _skillsError = null;
          _messageColor = Colors.grey;
        }
      });

      if (tags.isEmpty) {
        return;
      }
    }

    final isLastStep = currentStep == getSteps().length - 1;
    if (isLastStep) {
      _submitIdea();
    } else {
      context.read<PostBloc>().add(NextStep());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => PostBloc(
        announcementRepository: AnnouncementRepository(
          firestore: FirebaseFirestore.instance,
        ),
      ),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              if (state is SubmissionState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PostStepState) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: const Color(0xFFFD5336),
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
                      final isLastStep = details.currentStep == getSteps().length - 1;
                      return Row(
                        children: [
                          if (details.currentStep != 0)
                            TextButton(
                              onPressed: details.onStepCancel,
                              style: TextButton.styleFrom(foregroundColor: Colors.grey),
                              child: const Text('Back'),
                            ),
                          TextButton(
                            onPressed: isLastStep ? _submitIdea : details.onStepContinue,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return <Step>[
      Step(
        title: Text('Project', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        content: Column(
          children: [
            const SizedBox(height: 5),
            Form(
              key: _projectNameFormKey,
              child: TextFormField(
                controller: _ideanameController,
                focusNode: _projectNameFocusNode,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'Project Name*',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: BorderSide(width: 1, color: isDarkMode ? Colors.white : TColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: BorderSide(width: 1, color: isDarkMode ? Colors.white : TColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: BorderSide(width: 2, color: TColors.borderPrimary),
                  ),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _descriptionFormKey,
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                maxLength: 250,
                controller: _ideadescriptionController,
                focusNode: _descriptionFocusNode,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'Describe your idea*',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: BorderSide(width: 1, color: isDarkMode ? Colors.white : TColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: BorderSide(width: 1, color: isDarkMode ? Colors.white : TColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    borderSide: BorderSide(width: 2, color: TColors.borderPrimary),
                  ),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your idea';
                  } else if (value.length < 50) {
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
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.black87,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        isActive: true,
        state: StepState.indexed,
      ),
      Step(
        title: Text('Needed Members', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
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
        title: Text('Skills', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
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
                    _messageColor = Colors.grey;
                  }
                  if (!topSkills.contains(selectedTag)) {
                    topSkills.add(selectedTag);
                  }
                });
              },
fieldViewBuilder: (
  BuildContext context, 
  TextEditingController textEditingController, 
  FocusNode focusNode, 
  VoidCallback onFieldSubmitted
) {
  return TextFormField(
    controller: textEditingController,
    focusNode: focusNode,
    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
    decoration: InputDecoration(
      hintText: 'Search and add more skills',
      hintStyle: TextStyle(
        color: isDarkMode ? Colors.grey : Colors.black54,
        fontSize: 13,
        fontWeight: FontWeight.normal,
      ),
      suffixIcon: textEditingController.text.isNotEmpty
          ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                textEditingController.clear();
                focusNode.requestFocus(); // Keep the focus on the field after clearing
              },
            )
          : null, // Do not display if text is empty
      border: InputBorder.none,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: isDarkMode ? Colors.white : TColors.grey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: TColors.borderPrimary, width: 2),
      ),
    ),
    onChanged: (text) {
      // Force rebuild to show/hide clear icon dynamically
      setState(() {});
    },
  );
},
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    elevation: 4,
                    child: Container(
                      width: 325,
                      height: 220,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(1.0),
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
                                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                              ),
                              tileColor: isDarkMode ? Colors.grey[800] : Colors.white,
                              hoverColor: isDarkMode ? Colors.blueGrey : const Color(0xFFFD5336),
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
                  label: Text(skill, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                  selected: tags.contains(skill),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        tags.add(skill);
                        _messageColor = Colors.grey;
                      } else {
                        tags.remove(skill);
                      }
                    });
                  },
                  backgroundColor: isDarkMode ? Colors.grey[500] : Colors.white70,
                  selectedColor: const Color(0xFFFD5336),
                  showCheckmark: true,
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _skillsError ?? ' select at least one skill*',
                style: TextStyle(color: _messageColor, fontSize: 13),
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
