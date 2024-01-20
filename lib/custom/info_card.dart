import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InfoCard extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color warna;
  Function onPressed;

  InfoCard({super.key, 
    required this.text,
    required this.icon,
    required this.warna,
    required this.onPressed,
  });

  @override
  // ignore: library_private_types_in_public_api
  _InfoCardState createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
        child: ListTile(
          leading: Icon(
            widget.icon,
            color: widget.warna,
            size: 30.0,
          ),
          title: Text(
            widget.text,
            style: const TextStyle(
              fontFamily: 'MaisonNeue',
              fontSize: 15.0,
              color: Colors.black,
              fontWeight: FontWeight.w700
            ),
          ),
        ),
      ),
    );
  }
}