import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weighty/utils/constants.dart';

class Avatar extends StatelessWidget {
  final String? url;
  final VoidCallback? onTap;
  const Avatar({super.key, this.url, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url ?? "",
      errorWidget: (context, url, error) => Padding(
        padding:
            EdgeInsets.symmetric(horizontal: SizeConstrains.DEFAULT_PADDING),
        child: SvgPicture.asset(
          "assets/svgs/icons/user-icon.svg",
          width: 2,
        ),
      ),
      imageBuilder: (context, imageProvider) {
        return Container(
          margin:
              EdgeInsets.symmetric(horizontal: SizeConstrains.DEFAULT_PADDING),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider)),
        );
      },
    );
  }
}
