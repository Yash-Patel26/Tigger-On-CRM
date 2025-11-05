import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../presentation/pages/widgets/animated_glowing_logo.dart';
import '../../../presentation/pages/widgets/splash_background.dart';
import '../../../core/utils/page_transitions.dart';
import 'login_screen.dart' as login;
import '../../../shared/utils/connectivity_helper.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _proceedToFullLogin() async {
    // Check internet connectivity first
    final bool hasInternet = await ConnectivityHelper.hasInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        ConnectivityHelper.showNoInternetDialog(context);
      }
      return;
    }

    final String workspace = _emailController.text.trim().toLowerCase();

    // Check if workspace is real estate related
    bool isRealEstate = workspace.contains('realestate');

    if (!isRealEstate) {
      // Show error dialog for non-real estate workspaces
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Access Restricted'),
            content: const Text(
              'This application is only available for real estate companies.\n\n'
              'Please enter "realestate" as your workspace name.\n\n'
              'Please contact your administrator if you believe this is an error.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Proceed to login for real estate workspaces
    Navigator.of(context).push(
      SmoothPageTransitions.slideFromRight<void>(
        child: const login.LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color baseCard =
        Theme.of(context).cardTheme.color ??
        Theme.of(context).colorScheme.surface;
    final Color glass = baseCard.withOpacity(isDark ? 0.35 : 0.65);

    return Scaffold(
      body: SplashBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AnimatedGlowingLogo(
                    child: Image.asset(
                      'assets/favicon.webp',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sign in to your workspace',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter Your TiggerOn's Workspace",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: glass,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              isDark ? 0.08 : 0.12,
                            ),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.20 : 0.06,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.work_outline_rounded,
                                    size: 18,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Workspace Details',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  labelText: 'Enter your-workspace',
                                  hintText: 'your-workspace',
                                  suffixText: '.netcrm.co.in',
                                ),
                                // Validation removed
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _proceedToFullLogin,
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
