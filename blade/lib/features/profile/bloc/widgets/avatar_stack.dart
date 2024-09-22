// Path: lib/features/profile/widgets/avatar_stack.dart

import 'package:flutter/material.dart';
import '../repository/project_idea_repository.dart';
import 'avatar.dart'; // Correct import for AvatarWidget

class AvatarStack extends StatelessWidget {
  final List<String> userIds;
  final ProjectIdeaRepository repository;
  final double screenWidth;

  AvatarStack(
      {required this.userIds,
      required this.repository,
      required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final avatarSize = screenWidth * 0.07;
    final maxVisibleAvatars = 3;
    final hasExtraAvatars = userIds.length > maxVisibleAvatars;

    final stackWidth =
        (hasExtraAvatars ? (maxVisibleAvatars + 1) : userIds.length) *
            avatarSize *
            0.6;

    return SizedBox(
      width: stackWidth,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0;
              i < (hasExtraAvatars ? maxVisibleAvatars : userIds.length);
              i++)
            Positioned(
              left: i * (avatarSize * 0.6),
              top: 0,
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: AvatarWidget(
                  // Corrected from Avatar to AvatarWidget
                  userId: userIds[i],
                  repository: repository,
                ),
              ),
            ),
          if (hasExtraAvatars)
            Positioned(
              left: maxVisibleAvatars * (avatarSize * 0.6),
              top: 0,
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFD9D9D9),
                  radius: avatarSize * 0.5,
                  child: Text(
                    '+${userIds.length - maxVisibleAvatars}',
                    style: const TextStyle(color: Color(0xFFFD5336)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
