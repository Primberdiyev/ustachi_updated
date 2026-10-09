import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class MasterCardItemModel extends Equatable {
  final String name;
  final String job;
  final String experience;
  final String price;
  final double? rating;
  final String imageUrl;
  final String location;

  final String phone;

  final Function(BuildContext context)? onTap;

  const MasterCardItemModel({
    required this.name,
    required this.job,
    required this.experience,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.location,
    this.phone = '',
    this.onTap,
  });

  @override
  List<Object?> get props => [
        job,
        experience,
        price,
        rating,
        imageUrl,
        onTap,
        location,
        phone,
      ];
}
