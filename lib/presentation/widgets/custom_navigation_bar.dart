import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Gradient? backgroundGradient;

  const CustomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.backgroundGradient,
  }) : super(key: key);

  static const _icons = [
    Icons.home_outlined,
    Icons.search_outlined,
    Icons.analytics_outlined,
    Icons.history_outlined,
    Icons.person_outline,
  ];
  static const _iconsSelected = [
    Icons.home,
    Icons.search,
    Icons.analytics,
    Icons.history,
    Icons.person,
  ];
  static const _labels = [
    'Home',
    'Search',
    'Analytics',
    'History',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Pill indicator uses a light overlay of primaryLightColor
    final pillColor = AppTheme.primaryLightColor.withOpacity(0.25);
    final selIconColor = AppTheme.primaryColor;
    final unselIconColor = Colors.white70;
    final selLabelColor = AppTheme.primaryColor;
    final unselLabelColor = Colors.white70.withOpacity(0.8);

    // Default bluish gradient from your theme
    final defaultGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppTheme.primaryDarkColor,
        AppTheme.primaryColor,
      ],
    );
    final grad = backgroundGradient ?? defaultGrad;

    final count = _icons.length;
    double alignmentX(int idx) => -1.0 + (2.0 * idx / (count - 1));

    return Container(
      decoration: BoxDecoration(gradient: grad),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Sliding pill background
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment(alignmentX(selectedIndex), 0),
                child: Container(
                  width: 72,
                  height: 40,
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              // Nav items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(count, (i) {
                  final isSel = i == selectedIndex;
                  return InkWell(
                    onTap: () => onDestinationSelected(i),
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 72,
                      height: 64,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              isSel ? _iconsSelected[i] : _icons[i],
                              key: ValueKey(isSel),
                              size: isSel ? 28 : 24,
                              color: isSel ? selIconColor : unselIconColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _labels[i],
                            style: TextStyle(
                              fontSize: isSel ? 12 : 11,
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.normal,
                              color: isSel ? selLabelColor : unselLabelColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
