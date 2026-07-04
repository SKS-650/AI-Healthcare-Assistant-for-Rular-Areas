import 'package:flutter/material.dart';

class FilterBottomSheet extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const FilterBottomSheet({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: filters.map((filter) {
          final selected = filter == selectedFilter;
          return ListTile(
            title: Text(filter),
            trailing: selected ? const Icon(Icons.check) : null,
            selected: selected,
            onTap: () {
              onSelected(filter);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }
}
