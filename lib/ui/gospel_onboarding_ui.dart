import 'package:flutter/material.dart';
import 'package:onboarding/onboarding.dart';
import 'package:by_faith_app/ui/gospel_profile_ui.dart'; // Assuming this is where the profile form will be handled
import 'package:hive_flutter/hive_flutter.dart';
import 'package:by_faith_app/models/gospel_profile_model.dart'; // New model for user profile

class GospelOnboardingUI extends StatefulWidget {
  const GospelOnboardingUI({super.key});

  @override
  State<GospelOnboardingUI> createState() => _GospelOnboardingUIState();
}

class _GospelOnboardingUIState extends State<GospelOnboardingUI> {
  late int index;
  final onboardingPagesList = <Widget>[
    Builder(
      builder: (context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What is the Romans Road to salvation?',
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'The Romans Road to salvation is a way of explaining the good news of salvation using verses from the book of Romans. The Romans Road is a simple yet powerful method of explaining why we need salvation, how God provided salvation, how we can receive salvation, and what are the results of salvation.',
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Builder(
      builder: (context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sin',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'The first verse on the Romans Road to salvation is Romans 3:23, “For all have sinned, and come short of the glory of God.” We have all sinned. We have all done things that are displeasing to God. There is no one who is innocent. Romans 3:10-18 gives a detailed picture of what sin looks like in our lives.',
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Builder(
      builder: (context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Judgement',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'The second Scripture on the Romans Road to salvation, Romans 6:23a, teaches us about the consequences of sin: “For the wages of sin is death.” The punishment that we have earned for our sins is death. Not just physical death, but eternal death!',
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Builder(
      builder: (context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Gift',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'The third verse on the Romans Road to salvation picks up in the middle of Romans 6:23b: “But the gift of God is eternal life through Jesus Christ our Lord.” Romans 5:8 declares, “But God demonstrates His own love toward us, in that while we were still sinners, Christ died for us.” Jesus Christ died for us! Jesus’ death paid for the price of our sins. Jesus’ resurrection proves that God accepted Jesus’ death as the payment for our sins.',
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Builder(
      builder: (context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Believe',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'The fourth stop on the Romans Road to salvation is Romans 10:9, “That if you confess with your mouth Jesus as Lord, and believe in your heart that God raised Him from the dead, you will be saved.” Because of Jesus’ death on our behalf, all we have to do is believe in Him, trusting His death as the payment for our sins - and we will be saved! Romans 10:13 says it again, “for everyone who calls on the name of the Lord will be saved.” Jesus died to pay the penalty for our sins and rescue us from eternal death. Salvation, the forgiveness of sins, is available to anyone who will trust in Jesus Christ as Lord and Savior.',
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Builder(
      builder: (context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'By Faith',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'The final aspect of the Romans Road to salvation is the results of salvation. Romans 5:1 has this wonderful message: “Therefore, since we have been justified through faith, we have peace with God through our Lord Jesus Christ.” Through Jesus Christ we can have a relationship of peace with God. Romans 8:1 says, “Therefore, there is now no condemnation for those who are in Christ Jesus." Because of Jesus’ death on our behalf, we will never be condemned for our sins. Finally, we have this precious promise of God from Romans 8:38-39: “For I am convinced that neither death nor life, neither angels nor demons, neither the present nor the future, nor any powers, neither height nor depth, nor anything else in all creation, will be able to separate us from the love of God that is in Christ Jesus our Lord.”',
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Builder(
      builder: (context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Decision',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Would you like to follow the Romans Road to salvation? If so, here is a simple prayer you can pray to God. Saying this prayer is a way to declare to God that you are relying on Jesus Christ for your salvation. The words themselves will not save you. Only faith in Jesus Christ can provide salvation! “God, I know that I have sinned against you and am deserving of punishment. But Jesus Christ took the punishment that I deserve so that through faith in Him I could be forgiven. With your help, I place my trust in You for salvation. Thank You for Your wonderful grace and forgiveness - the gift of eternal life! Amen!”',
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Have you made a decision for Christ because of what you have learned through the Romans Road to salvation? If so, please click on the “I trusted in Christ as Savior today” Fill out Profile.',
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const GospelProfileUi(isNewProfile: true),
                    ),
                  );
                },
                child: const Text('I trusted in Christ as Savior today - Fill out Profile'),
              ),
            ],
          ),
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    index = 0;
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Print the length of onboardingPagesList and current index
    print('onboardingPagesList length: ${onboardingPagesList.length}');
    print('Current index: $index');

    // Ensure startIndex is valid
    final safeIndex = index.clamp(0, onboardingPagesList.isNotEmpty ? onboardingPagesList.length - 1 : 0);

    return Scaffold(
      body: onboardingPagesList.isEmpty
          ? const Center(child: Text('No onboarding pages available'))
          : Onboarding(
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
              startIndex: safeIndex, // Use safeIndex to avoid assertion error
              buildFooter: (context, dragDistance, pagesLength, currentIndex, setIndex, slideDirection) {
                return DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(45.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Custom page indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(pagesLength, (i) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              width: 10.0,
                              height: 10.0,
                              decoration: BoxDecoration(
                                color: i == currentIndex ? Colors.blue : Colors.grey,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20), // Add vertical spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (currentIndex > 0) _previousButton(setIndex),
                            if (currentIndex > 0 && currentIndex < pagesLength - 1)
                              const SizedBox(width: 10),
                            if (currentIndex < pagesLength - 1) _nextButton(setIndex),
                            if (currentIndex == pagesLength - 1) _signupButton(context),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _signupButton(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            // If the user skips the profile creation, mark onboarding as complete
            _markOnboardingComplete();
            _navigateToHome(context);
          },
          child: const Text(
            "SKIP",
            style: TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const GospelProfileUi(isNewProfile: true),
              ),
            );
          },
          child: const Text('Fill out Profile'),
        ),
      ],
    );
  }

  Widget _nextButton(void Function(int index) setIndexCallback) {
    return Material(
      borderRadius: defaultBorderRadius,
      color: defaultPrimaryButtonColor,
      child: InkWell(
        borderRadius: defaultBorderRadius,
        onTap: () {
          if (index < onboardingPagesList.length - 1) {
            setIndexCallback(index + 1);
            setState(() {
              index = index + 1;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            'Next',
            style: nextButtonTextStyle,
          ),
        ),
      ),
    );
  }

  Widget _previousButton(void Function(int index) setIndexCallback) {
    return Material(
      borderRadius: defaultBorderRadius,
      color: defaultPrimaryButtonColor,
      child: InkWell(
        borderRadius: defaultBorderRadius,
        onTap: () {
          if (index > 0) {
            setIndexCallback(index - 1);
            setState(() {
              index = index - 1;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            'Previous',
            style: nextButtonTextStyle, // Reusing the same style for now
          ),
        ),
      ),
    );
  }

  void _markOnboardingComplete() async {
    // Use a separate box for app settings to store simple key-value pairs
    var settingsBox = await Hive.openBox<bool>('appSettings');
    await settingsBox.put('onboardingComplete', true);
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home'); // Assuming '/home' is your main app route
  }
}

// Define some basic styles for the onboarding pages
const pageTitleStyle = TextStyle(
  fontSize: 28.0,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const pageInfoStyle = TextStyle(
  fontSize: 16.0,
  color: Colors.black87,
);

const defaultBorderRadius = BorderRadius.all(Radius.circular(100.0));
const defaultPrimaryButtonColor = Colors.blue;
const nextButtonTextStyle = TextStyle(
  fontSize: 16.0,
  color: Colors.white,
);