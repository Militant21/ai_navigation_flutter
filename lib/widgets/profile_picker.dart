import 'package:flutter/material.dart';
import '../services/routing_engine.dart';

class ProfilePicker extends StatelessWidget {
  final ProfileKind value;
  final ValueChanged<ProfileKind> onChanged;
  const ProfilePicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, children: [
      _btn('Rövidebb', ProfileKind.short),
      _btn('Autópálya', ProfileKind.motorway),
      _btn('Gazdaságos', ProfileKind.eco),
    ]);
  }

  Widget _btn(String t, ProfileKind k) => OutlinedButton(
    onPressed: ()=> onChanged(k),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: value==k? const Color(0xFF1D70B8): const Color(0xFFDDDDDD)),
      backgroundColor: value==k? const Color(0xFFEEF6FF) : null,
    ),
    child: Text(t),
  );
}