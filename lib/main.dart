
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import your pages
import './pages/login_page/login_page/login_page.dart';
import 'pages/register_page/register_page.dart';
import './pages/forgot_password_page/forgot_password_page/forgot_password_page.dart';
import 'pages/profile_page/profile_page.dart';
import 'pages/main_page/main_page.dart';
import 'pages/add_recipe_page/add_recipe_page.dart';
import 'pages/favorite_page/favorite_page.dart';
import 'pages/recipe_page/recipe_page.dart';

// Import AuthService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure Firestore for offline support
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  print("Firebase initialized!");
  
  // Try to enable network in background without blocking app startup
  WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
    _initializeFirestoreNetwork();
  });
  
  runApp(const MyApp());
}

// Initialize network in background
void _initializeFirestoreNetwork() async {
  try {
    await FirebaseFirestore.instance.enableNetwork();
    print('Firestore network enabled successfully');
  } catch (e) {
    print('Background network initialization failed (may already be enabled): $e');
    // This is OK - network will be enabled when needed
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',

      // Start with AuthWrapper to check login status
      home: AuthWrapper(),

      // Define routes for navigation
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/profile': (context) => const ProfilePage(currentUserId: ''), // Will be overridden by AuthWrapper
        '/forgot': (context) => const ForgotPasswordPage(),
        '/home': (context) => const MainPage(),
        '/add_recipe': (context) => const AddRecipePage(currentUserId: '',),
        '/favorites': (context) => const FavoritePage(userId: '',),
        '/recipe': (context) => const RecipePage(recipeId: '',),
      },

      theme: ThemeData(
        primaryColor: const Color(0xFF1EAE98),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(
          primary: const Color(0xFF1EAE98),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1EAE98),
        ),
      ),
    );
  }
}

// AuthWrapper to handle authentication state and navigation
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Give Firebase a moment to initialize
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Check if user is already logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        print('User already logged in: ${currentUser.uid}');
        _currentUserId = currentUser.uid;
        
        // Ensure network is enabled for logged-in users
        try {
          await FirebaseFirestore.instance.enableNetwork();
          print('Network enabled for logged-in user');
        } catch (e) {
          print('Network enable may have failed: $e');
          // Continue anyway - auth service will handle offline
        }
      } else {
        print('No user logged in');
      }
    } catch (e) {
      print('Error checking auth state: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1EAE98)),
              SizedBox(height: 20),
              Text('Loading Recipe App...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    // If user is logged in, go to main page
    if (_currentUserId != null) {
      // You have two options here:

      // Option 1: Go directly to MainPage
      return const MainPage();

      // Option 2: Use ProfilePage with the userId
      // return ProfilePage(currentUserId: _currentUserId!);
    }

    // If no user is logged in, go to login page
    return const LoginPage();
  }
}

// Optional: Network status banner widget (add to your main pages)
class NetworkStatusBanner extends StatefulWidget {
  final Widget child;

  const NetworkStatusBanner({super.key, required this.child});

  @override
  State<NetworkStatusBanner> createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner> {
  final bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    // You can add connectivity monitoring here if needed
    // Requires connectivity_plus package
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Show offline banner when needed
        if (!_isOnline)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'You are offline. Some features may be limited.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

