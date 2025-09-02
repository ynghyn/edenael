import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/url_launcher_service.dart';

class NaelScreen extends StatefulWidget {
  const NaelScreen({super.key});

  @override
  State<NaelScreen> createState() => _NaelScreenState();
}

class _NaelScreenState extends State<NaelScreen> {
  List<MediaItem> mediaItems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNaelMedia();
  }

  Future<void> _loadNaelMedia() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.getNaelMedia();
      if (!mounted) return;
      
      setState(() {
        mediaItems = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('미디어를 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getMediaIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_arrow_rounded;
      case 'music':
        return Icons.music_note_rounded;
      default:
        return Icons.play_arrow_rounded;
    }
  }

  Color _getMediaColor(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return const Color(0xFF6366F1); // Primary blue
      case 'music':
        return const Color(0xFFF59E0B); // Secondary amber
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _getMediaLabel(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return 'Video';
      case 'music':
        return 'Music';
      default:
        return 'Media';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.video_library,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '나엘 미디어',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Description Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '비디오와 음악을 탭하면 해당 앱에서 열립니다',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          avatar: Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: _getMediaColor('video'),
                          ),
                          label: const Text('YouTube 비디오'),
                          backgroundColor: _getMediaColor('video').withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: _getMediaColor('video'),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Chip(
                          avatar: Icon(
                            Icons.music_note_rounded,
                            size: 18,
                            color: _getMediaColor('music'),
                          ),
                          label: const Text('YouTube Music'),
                          backgroundColor: _getMediaColor('music').withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: _getMediaColor('music'),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Media Grid
              Expanded(
                child: isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              '미디어를 불러오는 중...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : mediaItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_library_outlined,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '미디어 컨텐츠가 곧 추가됩니다',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: mediaItems.length,
                            itemBuilder: (context, index) {
                              final item = mediaItems[index];
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () async {
                                    try {
                                      if (item.type.toLowerCase() == 'music') {
                                        await UrlLauncherService.openYouTubeMusic(item.url);
                                      } else {
                                        await UrlLauncherService.openYouTubeVideo(item.url);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('미디어를 열 수 없습니다: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Thumbnail
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(item.thumbnailUrl),
                                              fit: BoxFit.cover,
                                              onError: (exception, stackTrace) {},
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.3),
                                                ],
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.6),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Icon(
                                                  _getMediaIcon(item.type),
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Content
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getMediaColor(item.type).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _getMediaLabel(item.type),
                                                style: TextStyle(
                                                  color: _getMediaColor(item.type),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}