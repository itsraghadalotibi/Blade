import 'package:blade_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'avatar_widget.dart';
import '../src/announcement_repository.dart';

class AvatarStackWidget extends StatelessWidget {
  final List<String> userIds;
  final AnnouncementRepository repository;
  final double screenWidth;

  const AvatarStackWidget(
      {super.key,
      required this.userIds,
      required this.repository,
      required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final avatarSize = screenWidth * 0.07; // Fixed size for all avatars
    const maxVisibleAvatars = 3; // Show a maximum of 3 avatars
    final hasExtraAvatars = userIds.length > maxVisibleAvatars;

    // Fixed width for the avatar stack based on the number of avatars
    final stackWidth =
        (hasExtraAvatars ? (maxVisibleAvatars + 1) : userIds.length) *
            avatarSize *
            0.6;

    // Wrap the Stack in a SizedBox with fixed width and height to maintain consistency
    return SizedBox(
      width: stackWidth,
      height: avatarSize, // Fixed height for all avatars
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Loop to display avatars with consistent size and alignment
          for (int i = 0;
              i < (hasExtraAvatars ? maxVisibleAvatars : userIds.length);
              i++)
            Positioned(
              left: i *
                  (avatarSize * 0.6), // Offset each avatar by 60% of its size
              top: 0, // Ensures avatars are aligned horizontally
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: AvatarWidget(
                  userId: userIds[i],
                  repository: repository,
                ),
              ),
            ),
          // If there are more than 4 avatars, show the +X avatar
          if (hasExtraAvatars)
            Positioned(
              left: maxVisibleAvatars *
                  (avatarSize * 0.6), // Place extra avatar at the end
              top: 0, // Ensures it is aligned horizontally
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: CircleAvatar(
                  backgroundColor: TColors.borderPrimary,  //0xFFD9D9D9
                  radius: avatarSize * 0.5, // Ensure consistent size
                  child: Text(
                    '+${userIds.length - maxVisibleAvatars}', // Display the number of extra avatars
                    style: const TextStyle(color: TColors.buttonPrimary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
