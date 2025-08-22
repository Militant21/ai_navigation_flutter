import 'package:flutter/material.dart';

class ZoomToggle extends StatelessWidget {
  final String mode; // 'near'|'mid'|'far'
  final ValueChanged<String> onChanged;
  const ZoomToggle({super.key, required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, children: [
      _btn('Közeli', 'near'),
      _btn('Közepes', 'mid'),
      _btn('Távoli',  'far'),
    ]);
  }

  Widget _btn(String t, String m) => OutlinedButton(
    onPressed: ()=> onChanged(m),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: mode==m? const Color(0xFF1D70B8): const Color(0xFFDDDDDD)),
      backgroundColor: mode==m? const Color(0xFFEEF6FF) : null,
    ),
    child: Text(t),
  );
}