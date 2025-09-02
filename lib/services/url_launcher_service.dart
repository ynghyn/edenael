import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class UrlLauncherService {
  /// Opens a YouTube video in the appropriate app or browser
  static Future<void> openYouTubeVideo(String url) async {
    final videoId = _extractVideoId(url);
    
    if (videoId == null) {
      // Fallback to opening the original URL
      await _launchUrl(url);
      return;
    }
    
    if (Platform.isIOS) {
      // Try to open YouTube app on iOS
      final youtubeAppUrl = 'youtube://watch?v=$videoId';
      final youtubeWebUrl = 'https://www.youtube.com/watch?v=$videoId';
      
      if (await canLaunchUrl(Uri.parse(youtubeAppUrl))) {
        await launchUrl(Uri.parse(youtubeAppUrl));
      } else {
        await _launchUrl(youtubeWebUrl);
      }
    } else {
      // For other platforms, open in browser
      await _launchUrl(url);
    }
  }
  
  /// Opens a YouTube Music track
  static Future<void> openYouTubeMusic(String url) async {
    final videoId = _extractVideoId(url);
    
    if (videoId == null) {
      await _launchUrl(url);
      return;
    }
    
    if (Platform.isIOS) {
      // Try YouTube Music app first, then YouTube app, then browser
      final youtubeMusicUrl = 'https://music.youtube.com/watch?v=$videoId';
      await _launchUrl(youtubeMusicUrl);
    } else {
      await _launchUrl(url);
    }
  }
  
  /// Opens a YouTube playlist
  static Future<void> openYouTubePlaylist(String playlistId) async {
    final playlistUrl = 'https://www.youtube.com/playlist?list=$playlistId';
    
    if (Platform.isIOS) {
      final youtubeAppUrl = 'youtube://playlist?list=$playlistId';
      
      if (await canLaunchUrl(Uri.parse(youtubeAppUrl))) {
        await launchUrl(Uri.parse(youtubeAppUrl));
      } else {
        await _launchUrl(playlistUrl);
      }
    } else {
      await _launchUrl(playlistUrl);
    }
  }
  
  /// Generic URL launcher
  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Open in external app
      );
    } else {
      throw Exception('Could not launch $url');
    }
  }
  
  /// Extracts video ID from YouTube URL
  static String? _extractVideoId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}