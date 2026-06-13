import 'package:flutter/material.dart';
import '../utils/env.dart' as env;

class ChatItem {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final int unreadCount;
  final bool isOnline;

  ChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    required this.unreadCount,
    required this.isOnline,
  });
}

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTesting = env.isTesting;
    final List<ChatItem> chats = [
      ChatItem(
        name: 'Alex Mercer',
        message: 'Hey, did you check the new E2E encryption protocol?',
        time: '5m',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        unreadCount: 2,
        isOnline: true,
      ),
      ChatItem(
        name: 'Elena Rostova',
        message: 'Let\'s schedule the security audit for tomorrow.',
        time: '30m',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        unreadCount: 0,
        isOnline: true,
      ),
      ChatItem(
        name: 'Stealth Support',
        message: 'Welcome to Shatter! Your secure communication starts here.',
        time: '1h',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        unreadCount: 0,
        isOnline: true,
      ),
      ChatItem(
        name: 'Marcus Aurelius',
        message: 'Waste no more time arguing about what a good man should be. Be one.',
        time: 'Yesterday',
        avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
        unreadCount: 0,
        isOnline: false,
      ),
      ChatItem(
        name: 'Shatter Core Devs',
        message: 'Devon: All test suites passed! Merging main.',
        time: '2d ago',
        avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
        unreadCount: 5,
        isOnline: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E13), // Rich dark violet-black
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 16),
              child: Text(
                'Chats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1724), // Sleek secondary dark color
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF242038).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF7C758E)),
                    hintText: 'Search chats...',
                    hintStyle: TextStyle(color: Color(0xFF7C758E), fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Chats List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // Avatar section with online indicator dot
                            Stack(
                              children: [
                                ClipOval(
                                  child: isTesting
                                      ? Container(
                                          width: 52,
                                          height: 52,
                                          color: const Color(0xFF5A4575),
                                          alignment: Alignment.center,
                                          child: Text(
                                            chat.name[0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Image.network(
                                          chat.avatarUrl,
                                          width: 52,
                                          height: 52,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 52,
                                              height: 52,
                                              color: const Color(0xFF5A4575),
                                              alignment: Alignment.center,
                                              child: Text(
                                                chat.name[0],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                if (chat.isOnline)
                                  Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981), // Emerald green
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF0F0E13),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),

                            // Chat details (Name & Last message snippet)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    chat.message,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: chat.unreadCount > 0
                                          ? const Color(0xFFD8B4FE)
                                          : const Color(0xFF7C758E),
                                      fontSize: 14,
                                      fontWeight: chat.unreadCount > 0
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Time & Unread counter
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  chat.time,
                                  style: const TextStyle(
                                    color: Color(0xFF7C758E),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (chat.unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B5CF6), // Violet badge
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                    ),
                                    child: Text(
                                      '${chat.unreadCount}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
