import 'package:flutter/material.dart';

/// Fallback képernyő: ha nincs letöltött térkép,
/// háttérben halvány logo, alul mozgatható/elrejthető panel.
/// Alapból NYITVA.
class NoMapFallback extends StatefulWidget {
  const NoMapFallback({super.key});

  @override
  State<NoMapFallback> createState() => _NoMapFallbackState();
}

class _NoMapFallbackState extends State<NoMapFallback> {
  bool _panelVisible = true;
  // Kezdő/mínusz/max arány a képernyő magasságához képest
  final double _initial = 0.35;
  final double _min = 0.15;
  final double _max = 0.85;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // átlátszó appbar nélkül – teljes képernyő
      body: Stack(
        children: [
          // Háttér logó
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Center(
                child: Image.asset(
                  'assets/ai_logo.png', // legyen meg az assets-ben
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Ha panel rejtve: kis "fül" gomb lent középen a megnyitáshoz
          if (!_panelVisible)
            Positioned(
              left: 0, right: 0, bottom: 20,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _panelVisible = true),
                  icon: const Icon(Icons.keyboard_arrow_up),
                  label: const Text('Menü megnyitása'),
                ),
              ),
            ),

          // Mozgatható alsó panel (DraggableScrollableSheet) – csak ha látható
          if (_panelVisible)
            _DraggableMenu(
              initial: _initial,
              min: _min,
              max: _max,
              onHide: () => setState(() => _panelVisible = false),
            ),
        ],
      ),
    );
  }
}

/// Külön widget a mozgatható menünek – átláthatóság kedvéért.
class _DraggableMenu extends StatelessWidget {
  final double initial, min, max;
  final VoidCallback onHide;

  const _DraggableMenu({
    required this.initial,
    required this.min,
    required this.max,
    required this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initial,
      minChildSize: min,
      maxChildSize: max,
      snap: true,
      builder: (context, scrollController) {
        // Kártya-szerű alsó panel
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).cardColor.withOpacity(0.96),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fogantyú + bezár gomb sor
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                      child: Row(
                        children: [
                          // fogantyú középen
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 44, height: 5,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).dividerColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          // Rejtés gomb
                          IconButton(
                            tooltip: 'Elrejtés',
                            onPressed: onHide,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),

                    // Görgethető tartalom
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        children: [
                          const Text(
                            'Nincs letöltött térkép',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tölts le egy régiót a „Térképek letöltése” menüben, '
                            'vagy lépj a beállításokhoz.',
                            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                          ),
                          const SizedBox(height: 14),

                          // Gombok
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/catalog'),
                            icon: const Icon(Icons.cloud_download),
                            label: const Text('Térképek letöltése'),
                          ),
                          const SizedBox(height: 10),

                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/settings'),
                            icon: const Icon(Icons.settings),
                            label: const Text('Beállítások'),
                          ),
                          const SizedBox(height: 10),

                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/home'),
                            icon: const Icon(Icons.map),
                            label: const Text('Indítás'),
                          ),
                          const SizedBox(height: 24),

                          // Extra hely-kímélő tippek
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text(
                            'Tippek:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          const Text('• A panelt fel/le húzva állíthatod a magasságát.'),
                          const Text('• A jobb felső „X” gombbal elrejtheted a panelt.'),
                          const Text('• Alul középen bármikor újra megnyithatod.'),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
