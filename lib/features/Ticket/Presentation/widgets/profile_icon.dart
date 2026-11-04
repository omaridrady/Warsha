import 'package:flutter/material.dart';

class ProfileIcon extends StatelessWidget {
  String? profileImage;
  ProfileIcon({super.key, this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.hardEdge,
        child: Image.network(
          (profileImage == null || profileImage!.isEmpty)
              ? "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
              : profileImage!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: SizedBox(width: 16,height: 16,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF0058be)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
