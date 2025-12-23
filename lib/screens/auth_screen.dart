import 'package:flutter/material.dart';
import 'home_screen.dart';


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: [

        const SizedBox(height: 40),

        Image.asset(
          'assets/welcomeMyWardrobe.png',
          width: 180,
        ),

        const SizedBox(height: 24),

        const Text(
          'Please Register',
          style: TextStyle(fontSize: 22),
        ),

        const SizedBox(height: 32),

        // Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text('Username'),
              const SizedBox(height: 6),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Value',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              const Text('Password'),
              const SizedBox(height: 6),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Value',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
)
    );
  }
}