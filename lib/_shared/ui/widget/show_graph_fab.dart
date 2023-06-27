import 'package:flutter/material.dart';

class ShowGraphFAB extends StatelessWidget {
  final String heroTag;

  const ShowGraphFAB({
    required this.heroTag,
    super.key,
  });

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        heroTag: heroTag,
        child: const Icon(Icons.share_rounded),
        onPressed: () {},
      );
}
