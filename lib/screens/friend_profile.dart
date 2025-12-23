import 'package:flutter/material.dart';

class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/logo.png', // Reusing the main logo or app_logo based on preference. design shows similar logo.
                    // The user asked to use the new logo sent.
                    // Let's use the new one: assets/app_logo.png
                    // But wait, the previous logo was assets/logo.png.
                    // I'll use assets/app_logo.png as requested.
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  // Workaround: if app_logo.png is the one with "My wardrobe", use that.
                  // To be safe I'll use 'assets/app_logo.png'
                ],
              ),
            ),
            // Just incase the stack alignment is off, let's adjust.
            // Actually, the logo is centered in the design.
            Center(
              child: Image.asset(
                'assets/app_logo.png',
                height: 50,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // Profile Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://placehold.co/100x100.png',
                    ), // Placeholder
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'babis heotis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'fashion-icon',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: const [
                  OutfitCard(
                    color: Colors.red,
                    title: 'chill cinema outfit',
                    description:
                        'saw Vougonia in this outfit... do not wear again',
                    initialLikes: 14,
                  ),
                  OutfitCard(
                    color: Colors.cyan,
                    title: 'go thrifting',
                    description: 'thrifted fit...to go thrifting',
                    initialLikes: 10,
                  ),
                  OutfitCard(
                    color: Color(0xFF7CB342), // Greenish
                    title: 'party tzous',
                    description: 'May 15th get ready idea',
                    initialLikes: 12,
                  ),
                  OutfitCard(
                    color: Colors.pinkAccent,
                    title: 'outfit uni thursday',
                    description: 'needs a black hoodie',
                    initialLikes: 213,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OutfitCard extends StatefulWidget {
  final Color color;
  final String title;
  final String description;
  final int initialLikes;

  const OutfitCard({
    super.key,
    required this.color,
    required this.title,
    required this.description,
    required this.initialLikes,
  });

  @override
  State<OutfitCard> createState() => _OutfitCardState();
}

class _OutfitCardState extends State<OutfitCard> {
  late int _likes;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.initialLikes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likes++;
      } else {
        _likes--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Light purple background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurpleAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Color Block
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(12),
              color: widget.color,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Heart Icon
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _toggleLike,
                      child: Container(
                        color: Colors.transparent, // Hit test area
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked
                                  ? Colors.black
                                  : Colors.black, // Design shows black outline
                              size: 24,
                            ),
                            Text(
                              '$_likes',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Text
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
