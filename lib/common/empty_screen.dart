import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class EmptyScreen extends StatelessWidget {
  final String _text;

  EmptyScreen({@required String text}) : _text = text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.sentiment_dissatisfied,
            size: 80,
            color: Color(0xFFC4C4C4),
          ),
          Divider(
            height: 10,
            color: Colors.transparent,
          ),
          Text(
            _text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFFC4C4C4),
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
