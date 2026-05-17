import 'package:flutter/material.dart';
import 'package:frontend/core/routes.dart';
import 'package:frontend/features/authen/services/account_services.dart';

class AccountPage extends StatefulWidget {
  final String username;
  final bool newAccount;

  const AccountPage({
    super.key,
    required this.username,
    required this.newAccount,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  static const List<String> _dietaryOptions = <String>[
    'Vegetarian',
    'Vegan',
    'Gluten free',
    'Dairy free',
    'Nut free',
    'Low sodium',
    'High protein',
    'Halal',
  ];

  final TextEditingController _notesController = TextEditingController(
    text: 'Keep dishes mild and avoid peanuts.',
  );

  final List<_RecipeCompletion> _recipeCompletion = const <_RecipeCompletion>[
    _RecipeCompletion(
      title: 'Grilled Chicken Bowl',
      subtitle: 'Protein-focused dinner',
      progress: 0.9,
      completed: true,
    ),
    _RecipeCompletion(
      title: 'Vegetable Curry',
      subtitle: 'Lunch prep in progress',
      progress: 0.65,
      completed: false,
    ),
    _RecipeCompletion(
      title: 'Berry Breakfast Parfait',
      subtitle: 'Quick breakfast option',
      progress: 0.4,
      completed: false,
    ),
  ];

  final Set<String> _selectedDietaryOptions = <String>{
    'Low sodium',
    'Nut free',
  };

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleDietaryRequirement(String option) {
    setState(() {
      if (_selectedDietaryOptions.contains(option)) {
        _selectedDietaryOptions.remove(option);
        return;
      }

      _selectedDietaryOptions.add(option);
    });
  }

  void _saveAccountPreferences() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account preferences saved.')));
  }

  void _signOut() {
    AuthService.clearSession();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  String _initialsFor(String username) {
    final parts = username.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0].toUpperCase()}${parts.last[0].toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completionPercent =
        _recipeCompletion.fold<double>(0, (sum, item) => sum + item.progress) /
        _recipeCompletion.length;
    final completedRecipes = _recipeCompletion
        .where((item) => item.completed)
        .length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: const Text('Account Management'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    child: Text(
                      _initialsFor(widget.username),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.newAccount
                              ? 'New account setup in progress'
                              : 'Manage your account preferences',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (widget.newAccount)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Finish your diet profile now so recipe recommendations match your needs.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.newAccount) const SizedBox(height: 20),
            _SectionCard(
              title: 'Dietary requirements',
              subtitle: 'Tap to add or remove preferences.',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _dietaryOptions.map((option) {
                  final selected = _selectedDietaryOptions.contains(option);
                  return FilterChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (_) => _toggleDietaryRequirement(option),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Diet notes',
              subtitle: 'Add allergies, ingredient preferences, or reminders.',
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Example: no peanuts, less spice, extra protein',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Recipe completion',
              subtitle: 'Track how far along your saved recipes are.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _CompletionMetricCard(
                          label: 'Completed',
                          value:
                              '$completedRecipes/${_recipeCompletion.length}',
                          icon: Icons.check_circle_outline,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CompletionMetricCard(
                          label: 'Average progress',
                          value: '${(completionPercent * 100).round()}%',
                          icon: Icons.auto_graph_rounded,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: completionPercent),
                  const SizedBox(height: 16),
                  ..._recipeCompletion.map(
                    (recipe) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: recipe.completed
                                  ? colorScheme.primaryContainer
                                  : colorScheme.secondaryContainer,
                              child: Icon(
                                recipe.completed
                                    ? Icons.done_rounded
                                    : Icons.hourglass_bottom_rounded,
                                color: recipe.completed
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recipe.subtitle,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      minHeight: 8,
                                      value: recipe.progress,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${(recipe.progress * 100).round()}%',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saveAccountPreferences,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CompletionMetricCard extends StatelessWidget {
  const _CompletionMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

class _RecipeCompletion {
  const _RecipeCompletion({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.completed,
  });

  final String title;
  final String subtitle;
  final double progress;
  final bool completed;
}
