import 'package:flutter/material.dart';

// ==================== MODEL ====================

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class FandomFaq {
  final String question;
  final String answer;
  final List<String> keywords;
  const FandomFaq(
      {required this.question, required this.answer, required this.keywords});
}

// ==================== FAQ DATA ====================
// Predefined fandom + app FAQs, per the AI Fan Helper requirement.
// Add more entries here any time — no code logic needs to change.

const List<FandomFaq> fandomFaqs = [
  FandomFaq(
    question: 'What is Fandom Verse?',
    answer:
        'Fandom Verse is your all-in-one app for exploring fandoms — like '
        'Spiderman and Venom — plus a store for official fandom merchandise '
        'and a calendar of fan events.',
    keywords: ['what', 'fandom', 'verse', 'app', 'about'],
  ),

  // ---------- Cart / Products ----------
  FandomFaq(
    question: 'How do I add a product to my cart?',
    answer:
        'Open Products, find an item, and tap the "Add" button on its card '
        '(or open the product and tap Add to Cart). It\'ll appear in My Cart '
        'right away.',
    keywords: ['add', 'cart', 'product', 'buy'],
  ),
  FandomFaq(
    question: 'How do I change the quantity of an item in my cart?',
    answer:
        'Open My Cart and use the + and – buttons next to each item. The '
        'quantity can\'t go above the available stock.',
    keywords: ['quantity', 'increase', 'decrease', 'cart', 'change', 'update'],
  ),
  FandomFaq(
    question: 'How do I remove an item from my cart?',
    answer:
        'In My Cart, tap the − button until the quantity reaches zero, and '
        'the item will be removed automatically.',
    keywords: ['remove', 'delete', 'cart', 'item'],
  ),
  FandomFaq(
    question: 'What products are available?',
    answer:
        'You can browse categories like Electronics, Gaming, Smart Watches, '
        'Earbuds, iPhones, and Girls Sneakers — use the category chips or '
        'search bar on the Products screen to find what you need.',
    keywords: ['products', 'available', 'categories', 'have', 'sell', 'catalog'],
  ),
  FandomFaq(
    question: 'Do you have electronics?',
    answer:
        'Yes — the Electronics category includes items like earbuds, smart '
        'watches, and iPhones. Tap the "Electronics" chip on the Products '
        'screen to filter.',
    keywords: ['electronics', 'gadgets', 'tech'],
  ),
  FandomFaq(
    question: 'Do you have gaming products?',
    answer:
        'Yes — check the "Gaming" category chip on the Products screen for '
        'gaming-related merchandise.',
    keywords: ['gaming', 'game', 'games'],
  ),
  FandomFaq(
    question: 'Do you sell smart watches or earbuds?',
    answer:
        'Yes, both are available under Electronics — you can search '
        '"smart watch" or "earbuds" directly in the search bar too.',
    keywords: ['smart', 'watch', 'earbuds', 'earbud'],
  ),
  FandomFaq(
    question: 'Do you sell iPhones?',
    answer:
        'Yes — iPhones are listed under the Electronics category. Search '
        '"iPhone" or filter by Electronics to see current stock.',
    keywords: ['iphone', 'apple', 'phone'],
  ),
  FandomFaq(
    question: 'Do you have sneakers or shoes?',
    answer:
        'Yes — Girls Sneakers are available. Use the search bar or browse '
        'categories to find them.',
    keywords: ['sneakers', 'shoes', 'sneaker', 'footwear'],
  ),
  FandomFaq(
    question: 'How do I search or filter products?',
    answer:
        'Use the search bar at the top of Products to search by name, or '
        'tap a category chip (like Electronics or Gaming) to filter.',
    keywords: ['search', 'filter', 'category', 'find', 'products'],
  ),
  FandomFaq(
    question: 'What if a product is out of stock?',
    answer:
        'Out-of-stock products are marked "Out of stock" on their card and '
        'can\'t be added to your cart until more stock is available.',
    keywords: ['stock', 'unavailable', 'sold out', 'out'],
  ),

  // ---------- Wishlist ----------
  FandomFaq(
    question: 'What is the wishlist for?',
    answer:
        'Tap the heart icon on any product to save it to your Wishlist, so '
        'you can find it again later without searching.',
    keywords: ['wishlist', 'favorite', 'favourite', 'save', 'heart'],
  ),

  // ---------- Checkout / Orders ----------
  FandomFaq(
    question: 'How do I checkout / place an order?',
    answer:
        'From My Cart, tap "Proceed to Checkout", enter your shipping '
        'address and demo payment details, then tap "Place Order". '
        'Payments are simulated — no real card is charged.',
    keywords: ['checkout', 'order', 'place', 'pay', 'payment'],
  ),
  FandomFaq(
    question: 'Can I track my past orders?',
    answer:
        'Yes — your order history and status will be available from the '
        'Orders section of the app.',
    keywords: ['track', 'order', 'history', 'status'],
  ),
  FandomFaq(
    question: 'Is my payment information real / actually charged?',
    answer:
        'No. Fandom Verse\'s checkout is a demo only — no real payment '
        'processor is connected and no card is ever charged.',
    keywords: ['payment', 'real', 'charged', 'demo', 'card', 'safe'],
  ),

  // ---------- Fandoms ----------
  FandomFaq(
    question: 'What fandoms are on the app?',
    answer:
        'Fandom Verse currently features fandoms like Spiderman and Venom, '
        'with more being added regularly across categories like Movies and '
        'Superheroes.',
    keywords: ['fandom', 'fandoms', 'universe', 'which'],
  ),
  FandomFaq(
    question: 'Tell me about Spiderman fandom',
    answer:
        'Spiderman is one of the most iconic Marvel superheroes — created '
        'in 1962, his true identity is Peter Parker, a brilliant but '
        'socially awkward teen from Queens, New York.',
    keywords: ['spiderman', 'spider', 'peter parker'],
  ),
  FandomFaq(
    question: 'Tell me about Venom fandom',
    answer:
        'Venom is a complex anti-hero from Sony\'s Spider-Man Universe — a '
        'dual entity made up of journalist Eddie Brock and a sentient alien '
        'symbiote from the planet Klyntar.',
    keywords: ['venom', 'symbiote', 'eddie brock'],
  ),

  // ---------- Events ----------
  FandomFaq(
    question: 'Are there any events?',
    answer:
        'Yes — Fandom Verse lists fan events like conventions and expos '
        '(for example, a Car Expo in Karachi). Check the Events section for '
        'dates, locations, and details.',
    keywords: ['event', 'events', 'convention', 'expo', 'meetup'],
  ),

  // ---------- General app ----------
  FandomFaq(
    question: 'How do I log out?',
    answer:
        'Tap the menu icon (top-left) to open the drawer, then tap Logout '
        'at the bottom.',
    keywords: ['logout', 'log', 'out', 'sign out'],
  ),
  FandomFaq(
    question: 'What can you help me with?',
    answer:
        'I can help with browsing products, using your cart and wishlist, '
        'checking out, tracking orders, and answering questions about '
        'fandoms and events on Fandom Verse.',
    keywords: ['help', 'can you', 'assist', 'do'],
  ),
];

// ==================== MATCHING SERVICE ====================

class ChatbotService {
  /// Simple keyword-overlap matcher — no external API or internet needed.
  /// Scores each FAQ by how many of its keywords appear in the user's
  /// message, and returns the best match above a minimum threshold.
  String getResponse(String userMessage) {
    final normalized = userMessage.toLowerCase();

    FandomFaq? bestMatch;
    int bestScore = 0;

    for (final faq in fandomFaqs) {
      var score = 0;
      for (final keyword in faq.keywords) {
        if (normalized.contains(keyword)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        bestMatch = faq;
      }
    }

    if (bestMatch != null && bestScore > 0) {
      return bestMatch.answer;
    }

    return "I don't have an answer for that yet — try asking about "
        "products, categories, cart, checkout, orders, fandoms, or events. "
        "You can also tap one of the suggestions below.";
  }
}

// ==================== SCREEN ====================

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _service = ChatbotService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hi! I'm your Fandom Verse assistant. Ask me about products, "
          "cart, checkout, orders, fandoms, or events — or tap a suggestion "
          "below.",
      isUser: false,
    ),
  ];

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _messages.add(ChatMessage(text: _service.getResponse(text), isUser: false));
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D14),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF4F7CFF), Color(0xFF9B5CFF)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('AI Fan Helper',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _MessageBubble(message: _messages[index]),
            ),
          ),
          if (_messages.length <= 1) _SuggestionChips(onTap: _send),
          _InputBar(controller: _controller, onSend: _send),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? const LinearGradient(colors: [Color(0xFF4F7CFF), Color(0xFF9B5CFF)])
              : null,
          color: message.isUser ? null : const Color(0xFF161A24),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
        ),
        child: Text(message.text,
            style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4)),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _SuggestionChips({required this.onTap});

  static const _suggestions = [
    'How do I add to cart?',
    'What fandoms are on the app?',
    'Are there any events?',
    'Do you have iPhones?',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final text = _suggestions[index];
          return GestureDetector(
            onTap: () => onTap(text),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF161A24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(text,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161A24),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: onSend,
                  decoration: InputDecoration(
                    hintText: 'Ask something...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => onSend(controller.text),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF4F7CFF), Color(0xFF9B5CFF)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
