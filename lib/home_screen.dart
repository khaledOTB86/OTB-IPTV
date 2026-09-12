import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'xtream_service.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final XtreamService service;
  const HomeScreen({super.key, required this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _categories = [];
  List<dynamic> _channels = [];
  String? _selectedCategory;
  bool _loadingCategories = true;
  bool _loadingChannels = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await widget.service.getLiveCategories();
      setState(() {
        _categories = cats;
        _loadingCategories = false;
        if (cats.isNotEmpty) {
          _selectedCategory = cats.first['category_id'].toString();
          _loadChannels(_selectedCategory!);
        }
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
    }
  }

  Future<void> _loadChannels(String categoryId) async {
    setState(() => _loadingChannels = true);
    try {
      final chans = await widget.service.getLiveStreams(categoryId: categoryId);
      setState(() {
        _channels = chans;
        _loadingChannels = false;
      });
    } catch (e) {
      setState(() => _loadingChannels = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      appBar: AppBar(
        title: const Text('OTB ▶ IPTV', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: const Color(0xFF16181F),
        elevation: 0,
      ),
      body: _loadingCategories
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Row(
              children: [
                Container(
                  width: 140,
                  color: const Color(0xFF14151D),
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat['category_id'].toString() == _selectedCategory;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.redAccent.withOpacity(0.15),
                        title: Text(
                          cat['category_name'] ?? '',
                          style: TextStyle(
                            color: isSelected ? Colors.redAccent : Colors.white70,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          setState(() => _selectedCategory = cat['category_id'].toString());
                          _loadChannels(cat['category_id'].toString());
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _loadingChannels
                      ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _channels.length,
                          itemBuilder: (context, index) {
                            final channel = _channels[index];
                            final iconUrl = channel['stream_icon'] ?? '';
                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                final streamUrl = widget.service.buildStreamUrl(channel['stream_id']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerScreen(
                                      streamUrl: streamUrl,
                                      channelName: channel['name'] ?? 'Channel',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2029),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white10),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: iconUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: iconUrl,
                                              fit: BoxFit.contain,
                                              errorWidget: (_, __, ___) => const Icon(Icons.tv, color: Colors.white54, size: 36),
                                            )
                                          : const Icon(Icons.tv, color: Colors.white54, size: 36),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      channel['name'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
    );
  }
}
