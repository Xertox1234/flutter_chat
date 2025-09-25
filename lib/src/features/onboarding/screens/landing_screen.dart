import 'package:flutter/material.dart';
import 'package:seniors_companion_app/src/features/authentication/screens/login_screen.dart';
import 'package:seniors_companion_app/src/features/authentication/screens/registration_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _expandedFaqIndex;
  final TextEditingController _emailController = TextEditingController();
  bool _emailSubmitted = false;

  // Define sections for navigation
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  // Theme colors
  final Color primaryColor = const Color(0xFF4F46E5);
  final int trialDays = 14;

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleEmailSubmit() {
    if (_emailController.text.isNotEmpty) {
      setState(() {
        _emailSubmitted = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _emailSubmitted = false;
            _emailController.clear();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;
    final isMediumScreen = size.width < 1024;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 80), // Space for fixed navbar
                _buildHeroSection(isSmallScreen, isMediumScreen),
                _buildFeaturesSection(isSmallScreen),
                _buildTestimonialsSection(isSmallScreen),
                _buildPricingSection(isSmallScreen),
                _buildFaqSection(isSmallScreen),
                _buildSignUpSection(isSmallScreen),
                _buildFooter(),
              ],
            ),
          ),
          _buildNavigationBar(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(bool isSmallScreen) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              const Text(
                'Seniors Companion',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // Navigation Links
              if (!isSmallScreen) ...[
                Row(
                  children: [
                    _buildNavLink('Why you\'ll love it', () => _scrollToSection(_featuresKey)),
                    _buildNavLink('Testimonials', () => _scrollToSection(_testimonialsKey)),
                    _buildNavLink('Pricing', () => _scrollToSection(_pricingKey)),
                    _buildNavLink('FAQ', () => _scrollToSection(_faqKey)),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    // TODO: Implement mobile menu
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 80),
      child: Row(
        children: [
          // Text Content
          Expanded(
            flex: isMediumScreen ? 1 : 5,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 24 : 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay connected & independent',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 36 : 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.shade900,
                      height: 1.2,
                    ),
                    textAlign: isSmallScreen ? TextAlign.center : TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'with your voice companion',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 36 : 56,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      height: 1.2,
                    ),
                    textAlign: isSmallScreen ? TextAlign.center : TextAlign.left,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enjoy a friendly assistant that listens, reminds and chats with you. Try it free for $trialDays days—no credit card needed.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 22,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: isSmallScreen ? TextAlign.center : TextAlign.left,
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: isSmallScreen ? WrapAlignment.center : WrapAlignment.start,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Start Free Trial'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Show demo video
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Watch demo'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Hero Image
          if (!isSmallScreen)
            Expanded(
              flex: 4,
              child: Container(
                height: MediaQuery.of(context).size.height - 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=1200&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isSmallScreen) {
    final features = [
      {
        'icon': Icons.mic,
        'title': 'Friendly Voice Chat',
        'description': 'Enjoy natural, conversational interaction anytime you want to talk',
        'color': Colors.blue,
      },
      {
        'icon': Icons.medication,
        'title': 'Medication Reminders',
        'description': 'Never miss a dose—get gentle voice reminders right on time',
        'color': Colors.orange,
      },
      {
        'icon': Icons.access_time_filled,
        'title': 'Daily Schedule Assistance',
        'description': 'Stay organized with helpful prompts for appointments and tasks',
        'color': Colors.purple,
      },
    ];

    return Container(
      key: _featuresKey,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isSmallScreen ? 24 : 48),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            'FEATURES',
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The help you deserve, right when you need it',
            style: TextStyle(
              fontSize: isSmallScreen ? 32 : 42,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'From gentle reminders to cheerful conversation, our companion is designed exclusively for seniors\' peace of mind.',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            children: features.map((feature) {
              final color = feature['color'] as Color;
              return Container(
                width: isSmallScreen ? double.infinity : 350,
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            feature['description'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(bool isSmallScreen) {
    final testimonials = [
      {
        'quote': 'I love chatting with my new companion every morning—it reminds me about my pills and makes me smile.',
        'author': 'Eleanor Smith',
        'role': 'Retiree, 72',
      },
      {
        'quote': 'Setting reminders with just my voice is wonderful—no more sticky notes around the house!',
        'author': 'George Thompson',
        'role': 'Veteran, 68',
      },
      {
        'quote': 'It keeps me company in the evenings and even tells me jokes! I feel less lonely now.',
        'author': 'Maria Garcia',
        'role': 'Grandmother, 75',
      },
    ];

    return Container(
      key: _testimonialsKey,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isSmallScreen ? 24 : 48),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'TESTIMONIALS',
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loved by seniors everywhere',
            style: TextStyle(
              fontSize: isSmallScreen ? 32 : 42,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            children: testimonials.map((testimonial) {
              return Container(
                width: isSmallScreen ? double.infinity : 380,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey.shade300,
                          child: Text(
                            testimonial['author']![0],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              testimonial['author']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              testimonial['role']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '"${testimonial['quote']!}"',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(bool isSmallScreen) {
    return Container(
      key: _pricingKey,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isSmallScreen ? 24 : 48),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            'PRICING',
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Simple, transparent pricing',
            style: TextStyle(
              fontSize: isSmallScreen ? 32 : 42,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Start with a $trialDays-day free trial. No credit card required.',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _buildPricingCard(
                title: 'Starter',
                price: '\$59',
                period: '/year',
                description: 'Essential voice chat support and reminders for one household.',
                features: [
                  'Up to 2 users',
                  'Chat-based assistance',
                  'Medication scheduling & reminders',
                  'Emergency contacts',
                ],
                isPrimary: false,
                isSmallScreen: isSmallScreen,
              ),
              _buildPricingCard(
                title: 'Advanced',
                price: '\$149',
                period: '/year',
                description: 'Comprehensive safety & AI features for peace of mind.',
                features: [
                  'Up to 2 users',
                  'Full VAD voice interface',
                  'Fall detection alerts',
                  'Emergency contacts',
                  'AI assisted web search & OCR',
                  'Voice identification & personalization',
                ],
                isPrimary: true,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required bool isPrimary,
    required bool isSmallScreen,
  }) {
    return Container(
      width: isSmallScreen ? double.infinity : 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? primaryColor : Colors.grey.shade200,
          width: isPrimary ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPrimary)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Text(
                'MOST POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade500,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPrimary ? primaryColor : Colors.white,
                      foregroundColor: isPrimary ? Colors.white : primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Start free trial'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(bool isSmallScreen) {
    final faqs = [
      {
        'question': 'How long is the free trial?',
        'answer': 'Your free trial lasts for $trialDays days, giving you plenty of time to experience your new voice companion.',
      },
      {
        'question': 'Do I need a smart speaker or special device?',
        'answer': 'No, all you need is a smartphone or tablet with an internet connection and a microphone. We\'ll guide you through the quick setup.',
      },
      {
        'question': 'Can it remind me to take my medications?',
        'answer': 'Absolutely! Just tell the companion the medication name and time, and it will remind you with a friendly voice alert.',
      },
      {
        'question': 'Is my information private and secure?',
        'answer': 'Yes—your conversations and reminders are encrypted and never shared with third parties.',
      },
      {
        'question': 'Can my family check in on me through the app?',
        'answer': 'With your permission, loved ones can receive updates and know you\'re doing well.',
      },
    ];

    return Container(
      key: _faqKey,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isSmallScreen ? 24 : 48),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'FAQ',
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Frequently asked questions',
            style: TextStyle(
              fontSize: isSmallScreen ? 32 : 42,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: faqs.asMap().entries.map((entry) {
                final index = entry.key;
                final faq = entry.value;
                final isExpanded = _expandedFaqIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _expandedFaqIndex = isExpanded ? null : index;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  faq['question']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Text(
                            faq['answer']!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              height: 1.6,
                            ),
                          ),
                        ),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isSmallScreen ? 24 : 48),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            'Ready to meet your new companion?',
            style: TextStyle(
              fontSize: isSmallScreen ? 32 : 42,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Start your $trialDays-day free trial today and discover friendly support at your fingertips.',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: _emailSubmitted
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Thank you! Check your email to complete sign-up.',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _handleEmailSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Start Free Trial'),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            'By signing up, you agree to our Terms and Privacy Policy.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(32),
      color: Colors.grey.shade800,
      child: Text(
        '© 2023 Seniors Companion, Inc. All rights reserved.',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}