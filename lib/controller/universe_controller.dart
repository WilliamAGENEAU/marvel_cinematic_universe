import 'package:marvel_cinematic_universe/model/movie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UniverseController {
  final supabase = Supabase.instance.client;

  Future<List<Movie>> fetchUniverse() async {
    final response = await supabase
        .from('universe')
        .select()
        .order('id', ascending: true);

    return (response as List).map((m) => Movie.fromMap(m)).toList();
  }
}
