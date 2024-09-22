// Path: lib/features/profile/screens/edit_collaborator_profile_screen.dart

import 'dart:io'; // For File handling
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Image picker
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_collaborator_profile_bloc.dart';
import '../bloc/edit_collaborator_profile_event.dart';
import '../bloc/edit_collaborator_profile_state.dart';
import '../src/collaborator_profile_model.dart';

class EditCollaboratorProfileScreen extends StatefulWidget {
  final CollaboratorProfileModel profile;

  const EditCollaboratorProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _EditCollaboratorProfileScreenState createState() => _EditCollaboratorProfileScreenState();
}

class _EditCollaboratorProfileScreenState extends State<EditCollaboratorProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _skillsController;

  File? _newProfileImage; // Store the new profile image
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _skillsController = TextEditingController(text: widget.profile.skills?.join(', ') ?? '');
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path); // Set the new image