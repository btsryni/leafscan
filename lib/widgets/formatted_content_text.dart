import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A custom widget to parse and render paragraphs and bullet lists with justified text.
class FormattedContentText extends StatelessWidget {
  final String content;
  final double fontSize;
  final double height;

  const FormattedContentText({
    super.key,
    required this.content,
    this.fontSize = 12.0,
    this.height = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final hasBullets = content.contains('•');

    if (hasBullets) {
      final lines = content.split('\n');
      final listItems = <Widget>[];

      for (var line in lines) {
        var cleanLine = line.trim();
        if (cleanLine.startsWith('•')) {
          cleanLine = cleanLine.substring(1).trim();
        }
        if (cleanLine.isEmpty) continue;

        listItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom green circular bullet point indicator
                Container(
                  margin: const EdgeInsets.only(top: 6.0, right: 10.0),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    cleanLine,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: fontSize,
                      height: height,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: listItems,
      );
    } else {
      // Justified normal paragraph text
      return Text(
        content,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: fontSize,
          height: height,
          color: AppColors.textPrimary,
        ),
      );
    }
  }
}
