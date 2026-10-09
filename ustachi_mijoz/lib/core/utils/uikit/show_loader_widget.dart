import 'package:flutter/cupertino.dart';

class ShowLoaderWidget extends StatelessWidget {
  const ShowLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(),
    );
  }
}
