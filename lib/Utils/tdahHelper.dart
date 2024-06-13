import 'package:flutter/material.dart';

class TdahHelper extends StatefulWidget {
  @override
  _TdahHelperState createState() => _TdahHelperState();
}

class _TdahHelperState extends State<TdahHelper> {
  Offset _position = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _position = event.position;
        });
      },
      onExit: (event) {
        setState(() {
          _position = Offset(0, 0);
        });
      },
      child: Stack(
        children: [
          // Capa superior oscura (arriba del cursor)
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: _position.dy - 30,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // Capa inferior oscura (abajo del cursor)
          Positioned(
            left: 0,
            top: _position.dy + 30,
            right: 0,
            height: MediaQuery.of(context).size.height - _position.dy - 30,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}