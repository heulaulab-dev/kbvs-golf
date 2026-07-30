import 'package:flutter/material.dart';

/// Box-shadow tokens for the Golfie design system.
///
/// Sourced 1:1 from docs/DESIGN.md "Tokens — Spacing & Shapes → Shadows".
class GolfieShadows {
  const GolfieShadows._();

  static const List<BoxShadow> xl = <BoxShadow>[
    BoxShadow(color: Color(0x02000000), offset: Offset(0, 50), blurRadius: 40, spreadRadius: 0),
    BoxShadow(color: Color(0x05000000), offset: Offset(0, 50), blurRadius: 40, spreadRadius: 0),
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 20), blurRadius: 40, spreadRadius: 0),
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 3), blurRadius: 10, spreadRadius: 0),
  ];

  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
  ];

  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 12), blurRadius: 12, spreadRadius: 2),
    BoxShadow(color: Color(0x10000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -1),
  ];

  static const List<BoxShadow> md2 = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 16, spreadRadius: 0),
  ];

  static const List<BoxShadow> subtle = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 3, spreadRadius: 0),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 2, spreadRadius: -1),
  ];

  static const List<BoxShadow> md3 = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 12, spreadRadius: 0),
  ];
}