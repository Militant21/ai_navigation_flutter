import 'package:flutter/material.dart';
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Térképek letöltése')),
      body: const Center(child: Text('Itt lesz a régiók/közút/parkolók katalógusa.')),
    );
  }
}
