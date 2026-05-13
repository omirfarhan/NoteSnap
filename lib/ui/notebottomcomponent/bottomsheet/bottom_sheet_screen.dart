import 'package:flutter/material.dart';

class BottomSheetScreen extends StatelessWidget {
  final Function(Color) onThemeSelected;
  final Color? currentColor;

  const BottomSheetScreen({
    super.key,
    required this.onThemeSelected,
    this.currentColor,
  });

  static const List<Color> colors = [

    Color(0xFF137FA5),
    Color(0xFF09021f),
    Color(0xFF170b3d),
    Color(0xFF28185a),
    Color(0xFF3b2875),
    Color(0xFF554094),
    Color(0xFF8571bf),
    Color(0xFF180D60),
    Color(0xFF280053),
    Color(0xFF4A2F9B),
    Color(0xFF1A1A4A),
    Color(0xFF16066A),
    Color(0xFF15703A),
    Color(0xFF16704A),
    Color(0xFF012437),
    Color(0xFF2A6250),
    // Color(0xFF97CEAD),
    //Color(0xFFE5F3DD)
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height / 5,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Background",
              style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Regular'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final color = colors[index];

                  final isSelected = currentColor == color;

                  return GestureDetector(
                    onTap: () {

                      onThemeSelected(color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        color: color,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
