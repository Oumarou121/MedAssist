import 'package:flutter/material.dart';

class TreatScreen extends StatefulWidget {
  const TreatScreen({super.key});

  @override
  State<TreatScreen> createState() => _TreatScreenState();
}

class _TreatScreenState extends State<TreatScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Treat"));
  }
}
