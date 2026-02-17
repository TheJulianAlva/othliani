import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/onboarding_cubit.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onNext(BuildContext context) {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.read<OnboardingCubit>().completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      {'title': l10n.onboardingTitle1, 'description': l10n.onboardingDesc1},
      {'title': l10n.onboardingTitle2, 'description': l10n.onboardingDesc2},
      {'title': l10n.onboardingTitle3, 'description': l10n.onboardingDesc3},
    ];

    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go(RoutesTurista.folio);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.image,
                              size: 100,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            page['title']!,
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page['description']!,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _currentPage == index
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _onNext(context),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Icon(
                        _currentPage == pages.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
