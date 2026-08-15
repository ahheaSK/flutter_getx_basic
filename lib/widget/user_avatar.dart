import 'dart:io';

import 'package:flutter/material.dart';

import '../core/value/app_color.dart';
import '../data/model/user_model.dart';

/// Round profile picture with an initials fallback.
///
/// Three cases, in order:
/// 1. [localFile] — a photo just picked, not uploaded yet
/// 2. `user.fullImageUrl` — the stored image, fetched from `/api/files/...`
/// 3. initials — no image at all, or the network image failed to load
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.size = 44,
    this.localFile,
  });

  final UserModel user;
  final double size;
  final File? localFile;

  @override
  Widget build(BuildContext context) {
    final String? url = user.fullImageUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.primaryLight,
        border: Border.all(color: AppColor.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(url),
    );
  }

  Widget _buildContent(String? url) {
    if (localFile != null) {
      return Image.file(localFile!, fit: BoxFit.cover);
    }

    if (url != null) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        // The image route is public on the backend, so no auth header is
        // needed here — which is exactly why an <img>-style load works.
        errorBuilder: (_, _, _) => _initials(),
        loadingBuilder:
            (BuildContext context, Widget child, ImageChunkEvent? progress) {
              if (progress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
      );
    }

    return _initials();
  }

  Widget _initials() => Center(
    child: Text(
      user.initials,
      style: TextStyle(
        fontSize: size * 0.36,
        fontWeight: FontWeight.w600,
        color: AppColor.primary,
      ),
    ),
  );
}
