class Movie {
  final int id;
  final String name;
  final String phase;
  final String saga;
  final String time;
  final String thumbnail;
  final String date;
  final String? youtube;
  final String? music;
  final String niveau;
  final String? spoil;

  Movie({
    required this.id,
    required this.name,
    required this.phase,
    required this.thumbnail,
    this.spoil,
    required this.saga,
    required this.time,
    required this.date,
    this.youtube,
    this.music,
    required this.niveau,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      name: map['movie_name'],
      phase: map['phase'],
      saga: map['saga'],
      time: map['run_time'],
      thumbnail: map['thumbnail_url'],
      date: map['release_date'],
      youtube: map['youtube_id'],
      music: map['music_url'],
      niveau: map['niveau'],
      spoil: map['spoil'],
    );
  }
}
