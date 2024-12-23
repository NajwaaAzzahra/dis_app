import 'package:dis_app/models/user_model.dart';
import 'package:dis_app/pages/account/change_profile.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onPickImage;
  final User user;

  const ProfileHeader({Key? key, required this.onPickImage, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: DisHelperFunctions.screenHeight(context) * 0.300,
      decoration: const BoxDecoration(
        color: DisColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
      ),
      padding: const EdgeInsets.only(
        top: DisSizes.appBarHeight - 12,
        left: DisSizes.lg,
        right: DisSizes.md,
        bottom: DisSizes.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: DisHelperFunctions.screenWidth(context) * 0.3,
            height: DisHelperFunctions.screenWidth(context) * 0.3,
            decoration: BoxDecoration(
              color: DisColors.white,
              borderRadius: BorderRadius.circular(
                  DisHelperFunctions.screenWidth(context) * 0.3),
              border: Border.all(
                color: DisColors.white,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  DisHelperFunctions.screenWidth(context) * 0.3),
              child: user.photo != null
                  ? Image.network(user.photo!, fit: BoxFit.cover)
                  : Image.asset("assets/images/no_profile.jpeg"),
            ),
          ),
          Container(
            width: DisHelperFunctions.screenWidth(context) * 0.55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username!,
                  style: TextStyle(
                    color: DisColors.black,
                    fontSize: DisSizes.fontSizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DisSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCountInfo(user.followers.toString(), "Followers"),
                    _buildCountInfo(user.following.toString(), "Following"),
                  ],
                ),
                const SizedBox(height: DisSizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(Icons.edit, "Edit Profile", () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(
                        user: user,
                      )));
                    }),
                    _buildActionButton(Icons.add, "Upload", onPickImage),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountInfo(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: DisColors.black,
            fontSize: DisSizes.lg,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: DisColors.black,
            fontSize: DisSizes.fontSizeXs,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: DisSizes.sm,
        ),
        decoration: BoxDecoration(
          color: DisColors.white,
          borderRadius: BorderRadius.circular(DisSizes.buttonRadius),
        ),
        child: Row(
          children: [
            Icon(icon, size: DisSizes.iconSm, color: DisColors.black),
            const SizedBox(width: DisSizes.xs),
            Text(
              label,
              style: TextStyle(
                color: DisColors.black,
                fontSize: DisSizes.fontSizeXs,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
