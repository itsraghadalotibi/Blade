import 'package:blade_app/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../bloc/investment_request_bloc.dart';
import '../src/investment_request_model.dart';
import '../src/investment_request_repository.dart';
import 'investment_request_review.dart';

import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvestmentRequestFormScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const InvestmentRequestFormScreen({
    Key? key,
    required this.projectId,
    required this.projectTitle,
  }) : super(key: key);

  @override
  _InvestmentRequestFormScreenState createState() =>
      _InvestmentRequestFormScreenState();
}

class _InvestmentRequestFormScreenState
    extends State<InvestmentRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _customOfferController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _completePhoneNumber;
  DateTime? _validUntil;
  String? userId;
  String? userName;
  String? _selectedIconPath;
  bool showPhoneField = false;
  bool showEmailField = false;
  bool showCustomOfferField = false;

  // Icon paths
  final Map<String, String> _iconPaths = {
    'Financial Investment (Cash Funding)': 'assets/icons/money.svg',
    'Mentorship and Guidance': 'assets/icons/contract.svg',
    'Resource Provision (Equipment or Space)': 'assets/icons/program.svg',
    'Access to Accelerator Program': 'assets/icons/rocket.svg',
  };

  final List<String> _offerOptions = [
    'Financial Investment (Cash Funding)',
    'Mentorship and Guidance',
    'Resource Provision (Equipment or Space)',
    'Access to Accelerator Program',
    'Other',
  ];

  String? _selectedOfferOption;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    // Fetch the current user details from Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _emailController.text = user.email ?? ''; // Pre-fill email
      userName = await getUserName(userId!);
      setState(() {});
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('supporters')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final firstName = data?['firstName'] ?? '';
        final lastName = data?['lastName'] ?? '';
        return '$firstName $lastName'.trim();
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Unknown User';
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text('Are you sure you want to discard your changes?'),
            actions: <Widget>[
              OutlinedButton(
                style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                    ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                    ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _validUntil != null) {
      final offer = _selectedOfferOption == 'Other'
          ? _customOfferController.text.trim()
          : _selectedOfferOption;

      final contactInfo = {
        if (showEmailField) 'email': _emailController.text,
         if (showPhoneField && _completePhoneNumber != null) 'phone number': _completePhoneNumber!,
      };

      final request = InvestmentRequestModel(
        id: '',
        projectId: widget.projectId,
        projectName: widget.projectTitle,
        supporterId: userId!,
        supporterName: userName!,
        reasonForInterest: _reasonController.text.trim(),
        offer: offer!,
        contactInfo: contactInfo,
        createdAt: DateTime.now(),
        validUntil: _validUntil!,
        iconPath: _selectedIconPath ?? _iconPaths[offer]!,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => InvestmentRequestBloc(
              repository: InvestmentRequestRepository(),
            ),
            child: InvestmentRequestReviewScreen(request: request),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? TColors.dark : TColors.light;
    return WillPopScope(
      onWillPop: _onWillPop,

    child:  Scaffold(
      appBar: AppBar(
        title: const Text('Investment Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Project: ${widget.projectTitle}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Offer Options Dropdown with Icons
              DropdownButtonHideUnderline(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.9, // Adjust width to fit within the screen
                  child: DropdownButtonFormField<String>(
                    isExpanded: true, // Expands the dropdown to avoid overflow
                    dropdownColor: bgColor,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0), // Adds padding around the dropdown
                      labelText: 'Select an Offer*',
                      
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Adds rounded borders
                      ),
                    ),
                    value: _selectedOfferOption,
                    items: _offerOptions.map((offer) {
                      return DropdownMenuItem(
                        value: offer,
                        child: Row(
                          children: [
                            if (offer != 'Other')
                              SvgPicture.asset(
                                _iconPaths[offer]!,
                                height: 24,
                                width: 24,
                              ),
                            if (offer != 'Other') const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                offer,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedOfferOption = value;
                        showCustomOfferField = value == 'Other';
                        _selectedIconPath = value == 'Other'
                            ? 'assets/icons/money.svg'
                            : _iconPaths[value];
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select an offer' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Custom Offer Input and Icon Selection
              if (showCustomOfferField) ...[
                TextFormField(
                  controller: _customOfferController,
                  decoration: const InputDecoration(
                      labelText: 'Custom Offer Description'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please describe your offer'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Choose an Icon for Custom Offer',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _iconPaths.values.map((iconPath) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIconPath = iconPath;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedIconPath == iconPath
                                ? Colors.blue
                                : Colors.grey,
                            width: _selectedIconPath == iconPath
                              ? 3: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SvgPicture.asset(
                          iconPath,
                          height: 60,
                          width: 60,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              // Reason for Interest
              TextFormField(
                controller: _reasonController,
                maxLength: 300,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Reason for Interest*'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your reason for interest'
                    : null,
              ),
              const SizedBox(height: 16),

              // Date Selection Field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.grey, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    _validUntil == null
                        ? 'Select Validity Date'
                        : '${_validUntil!.toLocal()}'.split(' ')[0],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _validUntil ??
                          DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: isDarkMode
                                ? ColorScheme.dark(
                                    primary: Colors.blue[300]!,
                                    onPrimary: Colors.black,
                                    onSurface: Colors.white,
                                  )
                                : const ColorScheme.light(
                                    primary: Colors.blue,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: isDarkMode
                                    ? Colors.blue[200]!
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          child: Container(
                            color: Colors.grey.withOpacity(0.1),
                            child: child,
                          ),
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _validUntil = pickedDate;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Contact Information Section
                const Text('Contact Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showEmailField = !showEmailField;
                      });
                    },
                    child: Text(
                      showEmailField ? '− Remove Email' : '+ Add Email',
                      style: TextStyle(color: isDarkMode? Colors.blue[300]! :  Colors.blue, fontWeight: FontWeight.w500, fontSize: 14.0),
                    ),
                  ),
                  
                ],
              ),
              //const SizedBox(height: 16),
              if (showEmailField)
                Column(
                  children: [
                    //const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration:
                          const InputDecoration(labelText: 'Email Address'),
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address';
                        } else if (!RegExp(
                                r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    //const SizedBox(height: 16),
                  ],
                ),
                Row(
                  children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        showPhoneField = !showPhoneField;
                      });
                    },
                    child: Text(
                      showPhoneField
                          ? '− Remove Phone Number'
                          : '+ Add Phone Number',
                      style: TextStyle(color: isDarkMode? Colors.blue[300]! :  Colors.blue, fontWeight: FontWeight.w500, fontSize: 14.0),
                    ),
                  ),
                  ],
                  ),
              if (showPhoneField)
                Theme(
                  data: Theme.of(context).copyWith(
                    dialogBackgroundColor: bgColor,
                    dialogTheme: DialogTheme(
                      insetPadding: const EdgeInsets.all(20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    primaryColor: isDarkMode? Colors.blue[300]! : Colors.blue,
                  ),
                  child: IntlPhoneField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    initialCountryCode: 'SA',
                    onChanged: (phone) {
                    setState(() {
                      _completePhoneNumber = phone.completeNumber; // Capturing complete phone number
                    });
                  },
                    validator: (value) {
                      if (value == null) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Review Request'),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
