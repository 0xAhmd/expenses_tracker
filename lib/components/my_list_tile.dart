import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  const MyListTile(
      {super.key,
      required this.title,
      required this.trailing,
      required this.onEditPressed,
      required this.onDeletePressed});

  final String title;
  final String trailing;

  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(12),
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              onPressed: onDeletePressed,
              icon: Icons.delete,
            ),
            SlidableAction(
              borderRadius: BorderRadius.circular(12),
              backgroundColor: Colors.blue.shade400,
              foregroundColor: Colors.white,
              onPressed: onEditPressed,
              icon: Icons.edit,
            )
          ],
        ),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: Center(
            child: ListTile(
              title: Text(title),
              trailing: Text(
                trailing,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
