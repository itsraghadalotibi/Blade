import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../investment_request/bloc/investment_request_bloc.dart';
import '../../../investment_request/screens/requests_tab.dart';
import '../../../investment_request/src/investment_request_repository.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/supporter_profile_model.dart';
import 'edit_supporter_profile_screen.dart';
import '../bloc/edit_supporter_profile_bloc.dart'; // Import EditSupporterProfileBloc
import '../repository/profile_repository.dart'; // Import ProfileRepository
class SupporterProfileScreen extends StatefulWidget {
  final String userId;
  final bool showBackButton;

  const SupporterProfileScreen({
    Key? key,
    required this.userId,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  _SupporterProfileScreenState createState() => _SupporterProfileScreenState();
}

class _SupporterProfileScreenState extends State<SupporterProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentUserId;
  SupporterProfileModel? _updatedProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Two tabs: Investing and Invested
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = _currentUserId == widget.userId;

    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileViewBloc(
            profileRepository: context.read<ProfileRepository>(),
          )..add(LoadProfile(widget.userId)),
        ),
        BlocProvider(
          create: (context) => InvestmentRequestBloc(
            repository: context.read<InvestmentRequestRepository>(),
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          automaticallyImplyLeading: widget.showBackButton,
          actions: isOwner ? [_buildEditButton(context)] : null,
        ),
        body: _buildProfileContent(),
      ),
    );
  }

  IconButton _buildEditButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () async {
        final state = BlocProvider.of<ProfileViewBloc>(context).state;
        if (state is ProfileLoaded && state.profile is SupporterProfileModel) {
          final profile = _updatedProfile ?? state.profile as SupporterProfileModel;
          final updatedProfile = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => EditSupporterProfileBloc(
                  profileRepository: context.read(),
                ),
                child: EditSupporterProfileScreen(profile: profile),
              ),
            ),
          );

          if (updatedProfile != null && updatedProfile is SupporterProfileModel) {
            setState(() {
              _updatedProfile = updatedProfile;
            });
            context.read<ProfileViewBloc>().add(LoadProfile(widget.userId));
          }
        }
      },
    );
  }

  Widget _buildProfileContent() {
    return BlocBuilder<ProfileViewBloc, ProfileViewState>(
      builder: (context, state) {
        final profile = _updatedProfile ??
            (state is ProfileLoaded && state.profile is SupporterProfileModel
                ? state.profile as SupporterProfileModel
                : null);

        if (profile != null) {
          return _buildProfile(profile);
        } else if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('Unable to load profile.'));
      },
    );
  }

  Widget _buildProfile(SupporterProfileModel profile) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 70,
                  backgroundImage: profile.profilePhotoUrl != null
                      ? NetworkImage(profile.profilePhotoUrl!)
                      : const AssetImage('assets/images/user.png') as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.bio ?? 'No bio available',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ];
      },
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color,
            tabs: const [
              Tab(text: 'My requests'),
              //Tab(text: 'Invested'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OffersTab(supporterId: widget.userId),
                //const Center(child: Text('No completed projects yet.')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}