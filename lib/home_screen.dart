import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'xtream_service.dart';
import 'player_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> accountData;
  const HomeScreen({super.key, required this.accountData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentSection = 0; // 0: Dashboard, 1: Live, 2: Movies, 3: Series
  List<dynamic> _categories = [];
  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  String? _selectedCategory;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _loadSection(int sectionIndex) async {
    setState(() {
      _currentSection = sectionIndex;
      _isLoading = true;
      _selectedCategory = null;
      _items = [];
      _filteredItems = [];
      _searchController.clear();
    });

    final api = context.read<XtreamService>();

    try {
      if (sectionIndex == 1) {
        _categories = await api.getLiveCategories();
        _items = await api.getLiveStreams();
      } else if (sectionIndex == 2) {
        _categories = await api.getVodCategories();
        _items = await api.getVodStreams();
      } else if (sectionIndex == 3) {
        _categories = await api.getSeriesCategories();
        _items = await api.getSeries();
      }
      _filteredItems = _items;
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  void _filterByCategory(String? catId) async {
    setState(() {
      _selectedCategory = catId;
      _isLoading = true;
    });

    final api = context.read<XtreamService>();
    try {
      if (_currentSection == 1) {
        _items = await api.getLiveStreams(categoryId: catId);
      } else if (_currentSection == 2) {
        _items = await api.getVodStreams(categoryId: catId);
      } else if (_currentSection == 3) {
        _items = await api.getSeries(categoryId: catId);
      }
      _filteredItems = _items;
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _items;
      } else {
        _filteredItems = _items.where((item) {
          final name = (item['name'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0F),
      body: SafeArea(
        child: _currentSection == 0 ? _buildLandscapeDashboard() : _buildContentExplorer(),
      ),
    );
  }

  Widget _buildLandscapeDashboard() {
    final userInfo = widget.accountData['user_info'] ?? {};
    final expDate = userInfo['exp_date'] != null
        ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(userInfo['exp_date'].toString())! * 1000)
            .toString()
            .split(' ')[0]
        : 'Unlimited';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'OTB',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.white70, size: 28),
                    onPressed: () => _loadSection(1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, color: Colors.white70, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(accountData: widget.accountData),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161722),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Exp: $expDate',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _buildCinemaCard(
                  title: 'LIVE TV',
                  subtitle: 'بث مباشر للقنوات',
                  icon: Icons.live_tv_rounded,
                  colors: [const Color(0xFF0072FF), const Color(0xFF00C6FF)],
                  onTap: () => _loadSection(1),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildCinemaCard(
                  title: 'MOVIES',
                  subtitle: 'أفلام حسب الطلب',
                  icon: Icons.movie_creation_rounded,
                  colors: [const Color(0xFFD31027), const Color(0xFFEA384D)],
                  onTap: () => _loadSection(2),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildCinemaCard(
                  title: 'SERIES',
                  subtitle: 'أحدث المسلسلات',
                  icon: Icons.video_collection_rounded,
                  colors: [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
                  onTap: () => _loadSection(3),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User: ${userInfo['username'] ?? 'User'}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const Text(
                'Ultra Fast Native Engine • 60 FPS',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentExplorer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF12131A),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => setState(() => _currentSection = 0),
              ),
              const SizedBox(width: 8),
              Text(
                _currentSection == 1
                    ? 'LIVE TV'
                    : _currentSection == 2
                        ? 'MOVIES'
                        : 'SERIES',
                style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'بحث فوري...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                      filled: true,
                      fillColor: const Color(0xFF1E202B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final catId = isAll ? null : _categories[index - 1]['category_id'].toString();
              final catName = isAll ? 'الكل' : _categories[index - 1]['category_name'];
              final isSelected = _selectedCategory == catId;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(catName ?? ''),
                  selected: isSelected,
                  selectedColor: Colors.redAccent,
                  backgroundColor: const Color(0xFF1E202B),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 12),
                  onSelected: (_) => _filterByCategory(catId),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
              : _filteredItems.isEmpty
                  ? const Center(child: Text('لا توجد عناصر', style: TextStyle(color: Colors.white54)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _currentSection == 1 ? 5 : 4,
                        childAspectRatio: _currentSection == 1 ? 1.0 : 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final name = item['name'] ?? 'بدون اسم';
                        final iconUrl = item['stream_icon'] ?? item['cover'] ?? '';

                        return InkWell(
                          onTap: () {
                            final api = context.read<XtreamService>();
                            String playUrl = '';
                            if (_currentSection == 1) {
                              playUrl = api.buildLiveStreamUrl(item['stream_id']);
                            } else if (_currentSection == 2) {
                              playUrl = api.buildVodStreamUrl(item['stream_id'], item['container_extension']);
                            } else {
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(
                                  streamUrl: playUrl,
                                  title: name,
                                  isLive: _currentSection == 1,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF161722),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    child: iconUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: iconUrl,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) => const Icon(Icons.tv, color: Colors.white24, size: 36),
                                          )
                                        : const Icon(Icons.tv, color: Colors.white24, size: 36),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
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
    );
  }
}
