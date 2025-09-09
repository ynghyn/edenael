import 'dart:convert';
import 'package:http/http.dart' as http;

class Playlist {
  final String playlistId;
  final String title;
  final String thumbnailUrl;

  Playlist({
    required this.playlistId,
    required this.title,
    required this.thumbnailUrl,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      playlistId: json['playlistId'] ?? '',
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }
}

class MediaItem {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String type;
  final String url;

  MediaItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.type,
    required this.url,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      type: json['type'] ?? 'video',
      url: json['url'] ?? '',
    );
  }
}

class ApiService {
  // Your AWS Lambda URL
  static const String baseUrl = 'https://e3paoyoy8c.execute-api.us-west-1.amazonaws.com/prod';
  
  static Future<List<Playlist>> getPlaylists(String mood, String genre) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/playlists?mood=$mood&genre=$genre'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Playlist.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load playlists: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      print('API Error: $e - falling back to mock data');
      return _getMockPlaylists(mood, genre);
    }
  }
  
  // Fallback mock data
  static List<Playlist> _getMockPlaylists(String mood, String genre) {
    return [
      Playlist(
        playlistId: 'PL123abc789',
        title: '한국 CCM $mood 찬양 모음',
        thumbnailUrl: 'https://picsum.photos/300/300?random=1',
      ),
      Playlist(
        playlistId: 'PL456def012',
        title: '한국 워십 베스트 플레이리스트',
        thumbnailUrl: 'https://picsum.photos/300/300?random=2',
      ),
      Playlist(
        playlistId: 'PL789ghi345',
        title: 'CCM 한국 찬양팀 모음집',
        thumbnailUrl: 'https://picsum.photos/300/300?random=3',
      ),
      Playlist(
        playlistId: 'PL012jkl678',
        title: '$mood 한국 기독교 음악',
        thumbnailUrl: 'https://picsum.photos/300/300?random=4',
      ),
    ];
  }
  
  static Future<List<MediaItem>> getNaelMedia() async {
    // Mock data matching your web app
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      MediaItem(
        id: '1',
        title: '뿡뿡이 도전 혼자서 옷 입기',
        thumbnailUrl: 'https://img.youtube.com/vi/7hSze2nLTTU/maxresdefault.jpg',
        type: 'video',
        url: 'https://www.youtube.com/watch?v=7hSze2nLTTU',
      ),
      MediaItem(
        id: '2',
        title: '마귀들과 싸울지라',
        thumbnailUrl: 'https://img.youtube.com/vi/c0WVuloAaX8/maxresdefault.jpg',
        type: 'music',
        url: 'https://music.youtube.com/watch?v=c0WVuloAaX8',
      ),
      MediaItem(
        id: '3',
        title: '반짝아이 달려갑니다',
        thumbnailUrl: 'https://img.youtube.com/vi/M69rpIqHoIo/maxresdefault.jpg',
        type: 'music',
        url: 'https://music.youtube.com/watch?v=M69rpIqHoIo',
      ),
      MediaItem(
        id: '4',
        title: '뿡뿡이 치카치카',
        thumbnailUrl: 'https://img.youtube.com/vi/oFKKTmJezoY/maxresdefault.jpg',
        type: 'video',
        url: 'https://www.youtube.com/watch?v=oFKKTmJezoY',
      ),
      MediaItem(
        id: '5',
        title: '손 씻자',
        thumbnailUrl: 'https://img.youtube.com/vi/60sJ8Asirjw/maxresdefault.jpg',
        type: 'video',
        url: 'https://www.youtube.com/watch?v=60sJ8Asirjw',
      ),
      MediaItem(
        id: '6',
        title: '코끼리, 주전자, 개미',
        thumbnailUrl: 'https://img.youtube.com/vi/b55H7OQfzEk/maxresdefault.jpg',
        type: 'video',
        url: 'https://www.youtube.com/watch?v=b55H7OQfzEk',
      ),
    ];
  }
}