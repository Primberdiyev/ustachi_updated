import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/features/chat/presentation/view/chatting_page.dart';

@RoutePage()
class ChattingPageWrapper extends StatelessWidget {
  const ChattingPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChattingPage();
  }
}
