// Path: lib/features/profile/screens/collaborator_profile_screen.dart
import 'package:blade_app/utils/constants/colors.dart';
import 'package:blade_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_collaborator_profile_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/collaborator_profile_model.dart';
import '../screens/edit_collaborator_profile_screen.dart';
import '../screens/project_idea_card_widget.dart';
import '../repository/project_idea_repository.dart';
import '../src/project_idea_model.dart';

class CollaboratorProfileScreen extends StatefulWidget {
  final String userId;

  const CollaboratorProfileScreen({super.key, required this.userId});

  @override
  _CollaboratorProfileScreenState createState() =>
      _CollaboratorProfileScreenState();
}

class _CollaboratorProfileScreenState extends State<CollaboratorProfileScreen> {
  CollaboratorProfileModel? _updatedProfile;
  late ProjectIdeaRepository _projectIdeaRepository;
  Future<List<Idea>>? _futureIdeas;

  @override
  void initState() {
    super.initState();
    _projectIdeaRepository = ProjectIdeaRepository();
    _futureIdeas = _projectIdeaRepository.fetchIdeasByOwner(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileViewBloc(profileRepository: context.read())
        ..add(LoadProfile(widget.userId)),
      child: Scaffold(
        backgroundColor: TColors.dark, // Use theme background
        appBar: AppBar(
          title: const Text('Collaborator Profile'),
          backgroundColor: TColors.dark,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final state = BlocProvider.of<ProfileViewBloc>(context).state;
                if (state is ProfileLoaded &&
                    state.profile is CollaboratorProfileModel) {
                  final profile = _updatedProfile ??
                      state.profile as CollaboratorProfileModel;

                  // Navigate to EditCollaboratorProfileScreen with BlocProvider
                  final updatedProfile = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => EditCollaboratorProfileBloc(
                          profileRepository: context.read(),
                        ),
                        child: EditCollaboratorProfileScreen(profile: profile),
                      ),
                    ),
                  );

                  if (updatedProfile != null &&
                      updatedProfile is CollaboratorProfileModel) {
                    setState(() {
                      _updatedProfile = updatedProfile;
                    });

                    // Reload the profile data immediately after editing
                    context
                        .read<ProfileViewBloc>()
                        .add(LoadProfile(widget.userId));
                  }
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: BlocBuilder<ProfileViewBloc, ProfileViewState>(
            builder: (context, state) {
              final profile = _updatedProfile ??
                  (state is ProfileLoaded &&
                          state.profile is CollaboratorProfileModel
                      ? state.profile as CollaboratorProfileModel
                      : null);

              if (profile != null) {
                return buildCollaboratorProfile(profile);
              } else if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileError) {
                return Center(
                    child: Text('Error: ${state.message}',
                        style: const TextStyle(color: Colors.red)));
              }
              return const Center(child: Text('Unable to load profile.'));
            },
          ),
        ),
      ),
    );
  }

  Widget buildCollaboratorProfile(CollaboratorProfileModel profile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: profile.profilePhotoUrl != null
                ? NetworkImage(profile.profilePhotoUrl!)
                : const AssetImage('assets/images/user.png') as ImageProvider,
          ),
          const SizedBox(height: TSizes.md),
          Text(
            '${profile.firstName} ${profile.lastName}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: TColors.white, // Theme color
                ),
          ),
          const SizedBox(height: TSizes.sm),
          _buildSkillsChips(profile.skills ?? []),
          const SizedBox(height: TSizes.sm),
          _buildSocialMediaIcons(profile),
          const SizedBox(height: TSizes.sm),
          _buildAboutSection(profile.bio ?? 'No bio available'),
          const SizedBox(height: TSizes.sm),
          buildTabBarSection(),
        ],
      ),
    );
  }

  // Build smaller chips with theming
  Widget _buildSkillsChips(List<String> skills) {
    return Wrap(
      spacing: 8.0,
      children: skills.map((skill) {
        return Chip(
          label: Text(skill),
          backgroundColor: TColors.primary,
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TColors.white,
              ),
          padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
          visualDensity: VisualDensity.compact, // Make the chips smaller
        );
      }).toList(),
    );
  }

  // Social media icons (GitHub and LinkedIn)
  Widget _buildSocialMediaIcons(CollaboratorProfileModel profile) {
    final githubUrl = profile.socialMediaLinks?['GitHub'];
    final linkedInUrl = profile.socialMediaLinks?['LinkedIn'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialMediaIcon(
          icon: Icons.code, // GitHub icon
          url: githubUrl,
          activeColor: TColors.primary,
        ),
        const SizedBox(width: TSizes.md),
        _buildSocialMediaIcon(
          icon: Icons.business, // LinkedIn icon
          url: linkedInUrl,
          activeColor: TColors.primary,
        ),
      ],
    );
  }

  Widget _buildSocialMediaIcon({
    required IconData icon,
    required String? url,
    required Color activeColor,
  }) {
    return IconButton(
      icon: Icon(icon),
      color: url != null && url.isNotEmpty
          ? activeColor // Active color when URL is present
          : TColors.grey, // Gray when no URL is added
      onPressed: url != null && url.isNotEmpty
          ? () => _launchURL(url) // Open URL in browser if valid
          : null,
    );
  }

  void _launchURL(String url) {
    // Add your URL launch logic here, using package like `url_launcher`
  }

  Widget _buildAboutSection(String bio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: TColors.primary,
              ),
        ),
        const SizedBox(height: TSizes.sm),
        Text(
          bio,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TColors.white,
              ),
        ),
      ],
    );
  }

  Widget buildTabBarSection() {
    return DefaultTabController(
      length: 3, // Three tabs: Project Ideas, Ongoing, and Completed
      child: Column(
        children: [
          const TabBar(
            indicatorColor: TColors.primary,
            labelColor: TColors.primary,
            unselectedLabelColor: TColors.white,
            tabs: [
              Tab(text: 'Ideas'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
          ),
          SizedBox(
            height: 300, // Adjust the height of the tab content
            child: TabBarView(
              children: [
                buildProjectIdeasTab(),
                const Center(child: Text('Ongoing Projects content here...')),
                const Center(child: Text('Completed Projects content here...')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProjectIdeasTab() {
    return FutureBuilder<List<Idea>>(
      future: _futureIdeas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading ideas: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No project ideas found.',
              style: TextStyle(
                color: Color.fromARGB(
                    105, 122, 121, 121), // Use your theming folder color here
                fontSize: 14.0, // You can adjust the size as needed
              ),
            ),
          );
        }

        final ideas = snapshot.data!;

        return ListView.builder(
          itemCount: ideas.length,
          itemBuilder: (context, index) {
            final idea = ideas[index];
            return ProjectIdeaCardWidget(
              idea: idea,
              repository: _projectIdeaRepository,
            );
          },
        );
      },
    );
  }
}
