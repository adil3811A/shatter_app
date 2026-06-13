import 'package:flutter/material.dart';
import '../utils/env.dart' as env;

class Contact {
  final String name;
  final String status;
  final String avatarUrl;
  final bool isOnline;

  Contact({
    required this.name,
    required this.status,
    required this.avatarUrl,
    required this.isOnline,
  });
}

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTesting = env.isTesting;
    final List<Contact> favorites = [
      Contact(
        name: 'Alex Mercer',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        isOnline: true,
      ),
      Contact(
        name: 'Elena Rostova',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        isOnline: true,
      ),
      Contact(
        name: 'Devon Lane',
        status: 'Coding...',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        isOnline: true,
      ),
      Contact(
        name: 'Albert Flores',
        status: 'In a meeting',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        isOnline: false,
      ),
    ];

    final Map<String, List<Contact>> groupedContacts = {
      'A': [
        Contact(
          name: 'Albert Flores',
          status: 'In a meeting',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
          isOnline: false,
        ),
        Contact(
          name: 'Alex Mercer',
          status: 'Active',
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
          isOnline: true,
        ),
      ],
      'D': [
        Contact(
          name: 'Devon Lane',
          status: 'Coding...',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          isOnline: true,
        ),
      ],
      'E': [
        Contact(
          name: 'Elena Rostova',
          status: 'Active',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
          isOnline: true,
        ),
      ],
      'M': [
        Contact(
          name: 'Marcus Aurelius',
          status: 'Meditation',
          avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
          isOnline: false,
        ),
      ],
    };

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E13),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 16),
              child: Text(
                'Contacts',
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
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1724),
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
                    hintText: 'Search contacts...',
                    hintStyle: TextStyle(color: Color(0xFF7C758E), fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Main List
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Favorites Horizontal Header
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'FAVORITES',
                        style: TextStyle(
                          color: Color(0xFF7C758E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  // Favorites list
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 104,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final fav = favorites[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SizedBox(
                              width: 76,
                              child: Column(
                                children: [
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
                                                  fav.name[0],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : Image.network(
                                                fav.avatarUrl,
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
                                                      fav.name[0],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                      if (fav.isOnline)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981),
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
                                  const SizedBox(height: 6),
                                  Text(
                                    fav.name.split(' ')[0],
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),

                  // Grouped Contacts Section
                  ...groupedContacts.entries.map((entry) {
                    final letter = entry.key;
                    final list = entry.value;

                    return SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text(
                              letter,
                              style: const TextStyle(
                                color: Color(0xFF8B5CF6), // Violet key letters
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final contact = list[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                child: InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            ClipOval(
                                              child: isTesting
                                                  ? Container(
                                                      width: 44,
                                                      height: 44,
                                                      color: const Color(0xFF5A4575),
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        contact.name[0],
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  : Image.network(
                                                      contact.avatarUrl,
                                                      width: 44,
                                                      height: 44,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          width: 44,
                                                          height: 44,
                                                          color: const Color(0xFF5A4575),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            contact.name[0],
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),
                                            if (contact.isOnline)
                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF10B981),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: const Color(0xFF0F0E13),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                contact.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                contact.status,
                                                style: const TextStyle(
                                                  color: Color(0xFF7C758E),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                                          color: const Color(0xFF7C758E),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: list.length,
                          ),
                        ),
                      ],
                    );
                  }),

                  // Add bottom padding so content doesn't get covered by navigation bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
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
