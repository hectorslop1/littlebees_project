import 'package:flutter/material.dart';

class AppRadii {
  static const double smValue = 8.0;
  static const double mdValue = 12.0;
  static const double lgValue = 16.0;
  static const double xlValue = 20.0;
  static const double xxlValue = 24.0;
  
  static const Radius sm = Radius.circular(smValue);
  static const Radius md = Radius.circular(mdValue);
  static const Radius lg = Radius.circular(lgValue);
  static const Radius xl = Radius.circular(xlValue);
  static const Radius xxl = Radius.circular(xxlValue);

  static const BorderRadius borderRadiusSm = BorderRadius.all(sm);
  static const BorderRadius borderRadiusMd = BorderRadius.all(md);
  static const BorderRadius borderRadiusLg = BorderRadius.all(lg);
  static const BorderRadius borderRadiusXl = BorderRadius.all(xl);
  static const BorderRadius borderRadiusXxl = BorderRadius.all(xxl);
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(999.0));
}
