import 'package:flutter/material.dart';
import 'package:widgetbook/src/constants/brand_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widgetbook/src/providers/theme_provider.dart';
import '../utils/extensions.dart';

class BrandHandle extends StatelessWidget {
  const BrandHandle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeProvider = ThemeProvider.of(context)!;
    return Row(
      children: [
        // TODO add an own widget for this
        // or style the text button.icon appropriately
        // TODO make sure the onPresses is triggered on the text as well
        TextButton(
          onPressed: () async {
            if (await canLaunch(BrandConstants.discord)) {
              await launch(BrandConstants.discord);
            }
          },
          style: TextButton.styleFrom(
            splashFactory: InkRipple.splashFactory,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
            minimumSize: Size.zero,
            padding: const EdgeInsets.all(12),
          ),
          child: Icon(
            Icons.question_answer,
            color: themeProvider.state == ThemeMode.light
                ? context.theme.hintColor
                : context.colorScheme.primary,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        const Text('discord'),
      ],
    );
  }
}
