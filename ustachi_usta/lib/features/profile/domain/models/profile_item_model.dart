import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ProfileItemModel extends Equatable {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final WidgetBuilder? trailingBuilder;
  const ProfileItemModel({
    required this.title,
    required this.icon,
    required this.onTap,
    this.trailingBuilder,
  });
  @override
  List<Object?> get props => [
        title,
        icon,
        onTap,
        trailingBuilder,
      ];
}
