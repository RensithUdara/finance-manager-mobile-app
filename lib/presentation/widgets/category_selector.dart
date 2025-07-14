import 'package:flutter/material.dart';
import '../../core/constants/categories.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: Categories.expenseCategories.length,
      itemBuilder: (context, index) {
        final category = Categories.expenseCategories[index];
        final isSelected = category.name == selectedCategory;

        return InkWell(
          onTap: () => onCategorySelected(category.name),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? category.color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? category.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  color: isSelected ? category.color : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  category.name.split(' ').first,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? category.color : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
