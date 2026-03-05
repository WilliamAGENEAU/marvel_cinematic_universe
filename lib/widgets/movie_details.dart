import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class MovieDetails extends StatelessWidget {
  final Map<String, dynamic> movie;
  final VoidCallback onPlayVideo;
  final VoidCallback onToggleAudio;
  final VoidCallback onShowSpoil;
  final bool isAudioPaused;

  const MovieDetails({
    super.key,
    required this.movie,
    required this.onPlayVideo,
    required this.onToggleAudio,
    required this.onShowSpoil,
    required this.isAudioPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          movie["MoviewName"],
          textAlign: TextAlign.right,
          style: GoogleFonts.anton(fontSize: 26, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          "${movie["ReleaseDate"]}  •  ${movie["RunTime"]}",
          style: GoogleFonts.openSans(fontSize: 17, color: Colors.white70),
        ),
        const SizedBox(height: 14),
        _buildActionButtons(),
        if (movie["spoil"]?.toString().isNotEmpty ?? false)
          IconButton(
            onPressed: onShowSpoil,
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: onPlayVideo,
          icon: const Icon(FontAwesome5.play, color: Colors.white),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onToggleAudio,
          icon: Icon(
            isAudioPaused ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
