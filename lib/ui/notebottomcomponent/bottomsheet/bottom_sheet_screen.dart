import 'package:flutter/material.dart';

class BottomSheetScreen extends StatelessWidget {
  final Function(String? ) onThemeSelected;
  final String? currentBackground;
  const BottomSheetScreen({
    super.key,
    required this.onThemeSelected,
    this.currentBackground,
  });

  static const Map<String?, Color> backgrounds = {
    null: Color(0xFF137FA5),
    'assets/pic_1.jpg': Color(0xFF1A2320),
    'assets/pic_2.jpg': Color(0xFF091822),
    'assets/pic_3.jpg': Color(0xFF65857E),
    'assets/pic_4.jpg': Color(0xFF242934),
  };
  @override
  Widget build(BuildContext context) {
    final entries = backgrounds.entries.toList();

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
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final bg = entries[index].key;
                  final color = entries[index].value;
                  final isSelected = currentBackground == bg;

                  return GestureDetector(
                    onTap: () {
                      onThemeSelected(bg);
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
                        color: bg == null ? color : null,
                        image: bg != null
                            ? DecorationImage(
                          image: AssetImage(bg),
                          fit: BoxFit.cover,
                        )
                            : null,
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
