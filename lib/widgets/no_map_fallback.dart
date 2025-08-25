import 'package:flutter/material.dart';

class NoMapFallback extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onOpenCatalog;
  const NoMapFallback({super.key, this.onRetry, this.onOpenCatalog});

  @override
  Widget build(BuildContext context) {
    // nem háttérkép: kis logó + üzenet + 2 gomb
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // kicsi logó ikonszerűen
                SizedBox(
                  height: 96,
                  child: Image.asset('assets/icon-1024.png', fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nincs betöltött térképrégió.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tölts le egy régiót a Katalógusban, vagy próbáld újra.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onOpenCatalog,
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Katalógus'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Újra'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
