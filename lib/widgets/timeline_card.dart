import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TimelineCard extends StatelessWidget {
  final Map<String, dynamic> movie;
  final bool isActive;
  final bool isSeen;
  final double width;
  final double height;
  final VoidCallback onToggleSeen;

  const TimelineCard({
    super.key,
    required this.movie,
    required this.isActive,
    required this.isSeen,
    required this.width,
    required this.height,
    required this.onToggleSeen,
  });

  Color _getNiveauColor(String? niveau) {
    final level = niveau?.toLowerCase();
    return switch (level) {
      "immanquable" => Colors.redAccent,
      "interessant" || "intéressant" => Colors.orangeAccent,
      "optionnel" => Colors.greenAccent,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = movie["thumbnail_url"] ?? "";

    return AnimatedScale(
      duration: const Duration(milliseconds: 250),
      scale: isActive ? 1.08 : 1.0,
      curve: Curves.easeOutBack,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isSeen ? Colors.transparent : Colors.grey,
                isSeen ? BlendMode.dst : BlendMode.saturation,
              ),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: height,
                      width: width,
                      fit: BoxFit.cover,
                      memCacheWidth:
                          (width * MediaQuery.of(context).devicePixelRatio)
                              .round(),
                      placeholder: (context, url) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white12,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white24,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      height: height,
                      width: width,
                    ),
            ),
          ),
          Positioned(top: 6, right: 6, child: _buildCheckIcon()),
          Positioned(bottom: 12, left: 8, child: _buildNiveauBadge()),
        ],
      ),
    );
  }

  Widget _buildCheckIcon() {
    return GestureDetector(
      onTap: onToggleSeen,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSeen ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
          color: isSeen ? Colors.greenAccent : Colors.white,
        ),
      ),
    );
  }

  Widget _buildNiveauBadge() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: _getNiveauColor(movie["niveau"]),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
    );
  }
}
