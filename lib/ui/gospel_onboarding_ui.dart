import 'package:flutter/material.dart';
import 'package:onboarding/onboarding.dart';
import 'package:by_faith_app/ui/gospel_profile_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:by_faith_app/models/gospel_profile_model.dart'; // Not used in this snippet

class GospelOnboardingUI extends StatefulWidget {
  const GospelOnboardingUI({super.key});

  @override
  State<GospelOnboardingUI> createState() => _GospelOnboardingUIState();
}

class _GospelOnboardingUIState extends State<GospelOnboardingUI> {
  late int index;
  late List<Widget> onboardingPagesList;

  @override
  void initState() {
    super.initState();
    index = 0;
    onboardingPagesList = [
      Builder(
        builder: (context) => _buildPage(
          context,
          title: 'Welcome',
          subtitle: 'What is the Romans Road to salvation?',
          content:
              'The Romans Road to salvation is a way of explaining the good news of salvation using verses from the book of Romans. The Romans Road is a simple yet powerful method of explaining why we need salvation, how God provided salvation, how we can receive salvation, and what are the results of salvation.',
        ),
      ),
      Builder(
        builder: (context) => _buildPage(
          context,
          title: 'Sin',
          content:
              'The first verse on the Romans Road to salvation is Romans 3:23, “For all have sinned, and come short of the glory of God.” We have all sinned. We have all done things that are displeasing to God. There is no one who is innocent. Romans 3:10-18 gives a detailed picture of what sin looks like in our lives.',
        ),
      ),
      Builder(
        builder: (context) => _buildPage(
          context,
          title: 'Judgement',
          content:
              'The second Scripture on the Romans Road to salvation, Romans 6:23a, teaches us about the consequences of sin: “For the wages of sin is death.” The punishment that we have earned for our sins is death. Not just physical death, but eternal death!',
        ),
      ),
      Builder(
        builder: (context) => _buildPage(
          context,
          title: 'Gift',
          content:
              'The third verse on the Romans Road to salvation picks up in the middle of Romans 6:23b: “But the gift of God is eternal life through Jesus Christ our Lord.” Romans 5:8 declares, “But God demonstrates His own love toward us, in that while we were still sinners, Christ died for us.” Jesus Christ died for us! Jesus’ death paid for the price of our sins. Jesus’ resurrection proves that God accepted Jesus’ death as the payment for our sins.',
        ),
      ),
      Builder(
        builder: (context) => _buildPage(
          context,
          title: 'Believe',
          content:
              'The fourth stop on the Romans Road to salvation is Romans 10:9, “That if you confess with your mouth Jesus as Lord, and believe in your heart that God raised Him from the dead, you will be saved.” Because of Jesus’ death on our behalf, all we have to do is believe in Him, trusting His death as the payment for our sins - and we will be saved! Romans 10:13 says it again, “for everyone who calls on the name of the Lord will be saved.” Jesus died to pay the penalty for our sins and rescue us from eternal death. Salvation, the forgiveness of sins, is available to anyone who will trust in Jesus Christ as Lord and Savior.',
        ),
      ),
      Builder(
        builder: (context) => _buildPage(
          context,
          title: 'By Faith',
          content:
              'The final aspect of the Romans Road to salvation is the results of salvation. Romans 5:1 has this wonderful message: “Therefore, since we have been justified through faith, we have peace with God through our Lord Jesus Christ.” Through Jesus Christ we can have a relationship of peace with God. Romans 8:1 says, “Therefore, there is now no condemnation for those who are in Christ Jesus." Because of Jesus’ death on our behalf, we will never be condemned for our sins. Finally, we have this precious promise of God from Romans 8:38-39: “For I am convinced that neither death nor life, neither angels nor demons, neither the present nor the future, nor any powers, neither height nor depth, nor anything else in all creation, will be able to separate us from the love of God that is in Christ Jesus our Lord.”',
        ),
      ),
      Builder(
        builder: (context) => _buildDecisionPage(context),
      ),
    ];
  }

  Widget _buildPage(BuildContext context, {required String title, String? subtitle, required String content}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
                const SizedBox(height: 16.0),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionPage(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Decision',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Would you like to follow the Romans Road to salvation? If so, here is a simple prayer you can pray to God. Saying this prayer is a way to declare to God that you are relying on Jesus Christ for your salvation. The words themselves will not save you. Only faith in Jesus Christ can provide salvation! “God, I know that I have sinned against you and am deserving of punishment. But Jesus Christ took the punishment that I deserve so that through faith in Him I could be forgiven. With your help, I place my trust in You for salvation. Thank You for Your wonderful grace and forgiveness - the gift of eternal life! Amen!”',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Have you made a decision for Christ because of what you have learned through the Romans Road to salvation? If so, please click on the “Fill out Profile".',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'If you are already a Christian and have recieved Jesus Christ as your personal Saviour anytime other than today? Please click on the “Fill out Profile".',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = index.clamp(0, onboardingPagesList.isNotEmpty ? onboardingPagesList.length - 1 : 0);

    return Scaffold(
      body: onboardingPagesList.isEmpty
          ? const Center(child: Text('No onboarding pages available'))
          : Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(onboardingPagesList.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: i == index ? 12.0 : 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: i == index ? Theme.of(context).primaryColor : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Expanded(
                  child: Onboarding(
                    swipeableBody: onboardingPagesList,
                    onPageChanges: (
                      double netDragDistance,
                      int pagesLength,
                      int currentIndex,
                      SlideDirection slideDirection,
                    ) {
                      setState(() {
                        index = currentIndex;
                      });
                    },
                    startIndex: safeIndex,
                    buildFooter: (context, dragDistance, pagesLength, currentIndex, setIndex, slideDirection) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8.0,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isSmallScreen = constraints.maxWidth < 400;
                                    List<Widget> footerButtons = [];
                                    
                                    bool isFirstPage = currentIndex == 0;
                                    bool isLastPage = currentIndex == pagesLength - 1;
                                    bool isOnlyPage = pagesLength == 1; // True if first and last page are the same

                              Widget? leftButton;
                              Widget? rightButton;
                              MainAxisAlignment rowMainAxisAlignment = MainAxisAlignment.center;

                              if (isOnlyPage) {
                                  leftButton = _buildSkipButton(context);
                                  rightButton = _buildProfileButton(context);
                                  rowMainAxisAlignment = MainAxisAlignment.spaceBetween;
                              } else if (isFirstPage) {
                                  leftButton = _buildSkipButton(context);
                                  rightButton = _buildNextButton(setIndex);
                                  rowMainAxisAlignment = MainAxisAlignment.spaceBetween;
                              } else if (isLastPage) {
                                  leftButton = _buildPreviousButton(setIndex);
                                  rightButton = _buildProfileButton(context);
                                  // rowMainAxisAlignment remains MainAxisAlignment.center
                              } else { // Intermediate pages
                                  leftButton = _buildPreviousButton(setIndex);
                                  rightButton = _buildNextButton(setIndex);
                                  // rowMainAxisAlignment remains MainAxisAlignment.center
                              }

                              // Always use a Row for buttons, adjusting spacing based on screen size and button presence
                              return Row(
                                mainAxisAlignment: rowMainAxisAlignment,
                                children: [
                                  if (leftButton != null)
                                    Expanded(child: leftButton),
                                  if (leftButton != null && rightButton != null) ...[
                                    if (isFirstPage || isOnlyPage)
                                      const Spacer()
                                    else
                                      const SizedBox(width: 16.0),
                                  ],
                                  if (rightButton != null)
                                    Expanded(child: rightButton),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ), // Closing Onboarding
          ), // Closing Expanded
        ], // Closing children list of outer Column
      ), // Closing outer Column
    ); // Closing Scaffold
  }

  Widget _buildSkipButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        _markOnboardingComplete();
        _navigateToHome(context);
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        textStyle: const TextStyle(fontSize: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Consistent padding
      ),
      child: const Text('SKIP'),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _markOnboardingComplete(); // Mark onboarding complete when proceeding to profile
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GospelProfileUi(isNewProfile: true),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
      ),
      child: const Text(
        'Fill out Profile',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  Widget _buildNextButton(void Function(int index) setIndexCallback) {
    return ElevatedButton(
      onPressed: () {
        if (index < onboardingPagesList.length - 1) {
          setState(() {
            index++;
          });
          setIndexCallback(index); // Ensure Onboarding widget updates its page
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
      ),
      child: const Text(
        'Next',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  Widget _buildPreviousButton(void Function(int index) setIndexCallback) {
    return ElevatedButton(
      onPressed: () {
        if (index > 0) {
          setState(() {
            index--;
          });
          setIndexCallback(index); // Ensure Onboarding widget updates its page
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
      ),
      child: const Text(
        'Back',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  void _markOnboardingComplete() async {
    var settingsBox = await Hive.openBox<bool>('appSettings');
    await settingsBox.put('onboardingComplete', true);
  }

  void _navigateToHome(BuildContext context) {
     // Clear the navigation stack up to the first route and push home
    if (Navigator.of(context).canPop()) {
       Navigator.of(context).popUntil((route) => route.isFirst);
    }
    Navigator.of(context).pushReplacementNamed('/home');
  }
}