import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CollapsibleCard extends StatefulWidget {
  const CollapsibleCard({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });
  final String title;
  final Widget child;
  final Widget? action;

  @override
  State<CollapsibleCard> createState() => _CollapsibleCardState();
}

class _CollapsibleCardState extends State<CollapsibleCard> {
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () => setState(() => expanded = !expanded),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (widget.action != null) ...<Widget>[
                      widget.action!,
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      expanded
                          ? FontAwesomeIcons.chevronUp
                          : FontAwesomeIcons.chevronDown,
                    ),
                  ],
                ),
              ),
              if (expanded) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 12),
                  child: Divider(color: primary.withOpacity(0.15), height: 1),
                ),
                widget.child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
