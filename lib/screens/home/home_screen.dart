import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Model for gift suggestion
class GiftSuggestion {
  final String ageGroup;
  final String imageUrl;
  final String suggestion;
  final Color color;

  GiftSuggestion({
    required this.ageGroup,
    required this.imageUrl,
    required this.suggestion,
    required this.color,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Static gift suggestions with Google Image links and colors
  List<GiftSuggestion> getGiftSuggestions() {
    return [
      GiftSuggestion(
        ageGroup: '3-5 Years',
        imageUrl:
            'https://cdn.cdnparenting.com/articles/2019/06/19103510/Stuffed-Animals.webp',
        suggestion: 'Stuffed Animals',
        color: Colors.pink.shade100,
      ),
      GiftSuggestion(
        ageGroup: '6-10 Years',
        imageUrl:
            'https://www.lego.com/cdn/cs/set/assets/blt354cdb9826736318/10312.png?fit=crop&quality=80&width=400&height=400&dpr=1',
        suggestion: 'LEGO Building Set',
        color: Colors.blue.shade100,
      ),
      GiftSuggestion(
        ageGroup: '11-15 Years',
        imageUrl:
            'https://rukminim2.flixcart.com/image/850/1000/xif0q/learning-toy/y/l/d/curious-jr-science-experiment-kit-for-class-10th-pw-original-imah7kpac6gx8bgg.jpeg?q=20&crop=false',
        suggestion: 'Science Experiment Kit',
        color: Colors.green.shade100,
      ),
      GiftSuggestion(
        ageGroup: '16-20 Years',
        imageUrl:
            'https://cdn.thewirecutter.com/wp-content/media/2023/07/bluetoothheadphones-2048px-6109-2x1-1.jpg?width=2048&quality=75&crop=2:1&auto=webp',
        suggestion: 'Wireless Headphones',
        color: Colors.purple.shade100,
      ),
      GiftSuggestion(
        ageGroup: '21+ Years',
        imageUrl:
            'https://media.licdn.com/dms/image/v2/D5612AQHUSEnTkZbkVw/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1681303545943?e=2147483647&v=beta&t=XHxrhb2bw3b8JioeKtmAr8hSzDo0SUKwm2O9m4yQGrI',
        suggestion: 'Smartwatch',
        color: Colors.amber.shade100,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final giftSuggestions = getGiftSuggestions();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Gift Suggestions',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUserProfileSection(context, user),
          Expanded(
            child: _buildGiftSuggestionsList(context, giftSuggestions),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.blueGrey.shade800,
              content: const Text('Add new gift feature coming soon!'),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context, user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    user?.displayName ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    user?.email ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Gift Suggestions by Age Group',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftSuggestionsList(
      BuildContext context, List<GiftSuggestion> giftSuggestions) {
    return AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: giftSuggestions.length,
          itemBuilder: (context, index) {
            final gift = giftSuggestions[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blueGrey.shade800,
                          content: Text(
                            'More on "${gift.suggestion}" coming soon!',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.network(
                              gift.imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 180,
                                color: gift.color,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: gift.color,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    gift.ageGroup,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  gift.suggestion,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade100,
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}