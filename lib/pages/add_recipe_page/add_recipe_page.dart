import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import '../../services/user_service.dart';

class AddRecipePage extends StatefulWidget {
  final String currentUserId;
  const AddRecipePage({super.key, required this.currentUserId});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final Color primaryColor = const Color(0xFF1EAE98);

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();

  String? imageUrl;
  String selectedCategory = 'All';
  List<String> categories = ['All', 'breakfast', 'lunch', 'dinner'];
  String? currentUserName;

  String getCategoryId(String selected) {
    switch (selected.toLowerCase()) {
      case 'breakfast':
        return 'cat_breakfast';
      case 'lunch':
        return 'cat_lunch';
      case 'dinner':
        return 'cat_dinner';
      default:
        return 'all';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUserName();
  }

  void _loadCurrentUserName() async {
    if (widget.currentUserId.isEmpty) return;

    try {
      final user = await UserService().getUserById(widget.currentUserId);
      if (user != null) {
        setState(() {
          currentUserName = user.name;
        });
      }
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Add Recipe", style: TextStyle(color: Colors.black)),
        foregroundColor: Colors.black,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryColor,
                    child: Text(
                      currentUserName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUserName ?? 'Loading...',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "You're adding a new recipe",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recipe Name
            buildTextField("Recipe Name", nameController),

            // Category Selection
            const Text(
              "Select Category",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
                items: categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
                style: const TextStyle(color: Colors.black87),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            // Image URL
            const Text(
              "Image URL",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: imageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                hintText:
                    "Enter image URL (e.g., https://example.com/image.jpg)",
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                prefixIcon: const Icon(Icons.image, color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.black87),
              onChanged: (value) => setState(() => imageUrl = value),
            ),

            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Origin
            buildTextField("Origin (Country/Region)", originController),

            // Short Description
            buildTextField(
              "Short Description",
              descController,
              maxLines: 3,
              hintText: "Brief description about the recipe...",
            ),

            // Cooking Time
            buildTextField(
              "Cooking Time (e.g., 30 mins)",
              timeController,
              type: TextInputType.text,
            ),

            const SizedBox(height: 10),

            // Steps
            const Text(
              "Steps",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Write each step on a new line",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: stepsController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    "Step 1: Prepare ingredients...\nStep 2: Cook...\nStep 3: Serve...",
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.black87),
            ),

            const SizedBox(height: 20),

            // Ingredients
            const Text(
              "Ingredients",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Format: item:quantity (one per line or comma separated)",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: ingredientsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    "Flour:2 cups\nSugar:1/2 cup\nSalt:1 tsp\nEggs:2 pieces",
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.black87),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _saveRecipe,
                icon: const Icon(Icons.save, size: 22, color: Colors.white),
                label: const Text(
                  "Save Recipe",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            // Cancel Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRecipe() async {
    // Validation
    if (nameController.text.isEmpty) {
      _showError("Please enter recipe name");
      return;
    }

    if (stepsController.text.isEmpty) {
      _showError("Please add at least one step");
      return;
    }

    if (imageController.text.isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "No Image",
            style: TextStyle(color: Colors.black87),
          ),
          content: const Text("You haven't added an image. Continue anyway?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    // Parse ingredients
    final List<Ingredient> ingredients = [];
    final ingredientsText = ingredientsController.text.trim();

    if (ingredientsText.isNotEmpty) {
      // Try to parse by lines first
      List<String> ingredientLines = ingredientsText.split('\n');

      // If no newlines, try commas
      if (ingredientLines.length == 1 && ingredientsText.contains(',')) {
        ingredientLines = ingredientsText.split(',');
      }

      for (final line in ingredientLines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;

        final colonIndex = trimmedLine.indexOf(':');
        if (colonIndex != -1) {
          final item = trimmedLine.substring(0, colonIndex).trim();
          final quantity = trimmedLine.substring(colonIndex + 1).trim();
          ingredients.add(Ingredient(item: item, quantity: quantity));
        } else {
          // If no colon, treat the whole line as item
          ingredients.add(Ingredient(item: trimmedLine, quantity: ''));
        }
      }
    }

    // Parse steps
    final steps = stepsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    try {
      // Get current user name if not already loaded
      if (currentUserName == null || currentUserName!.isEmpty) {
        final user = await UserService().getUserById(widget.currentUserId);
        currentUserName = user?.name ?? 'User';
      }

      // Create recipe model WITH uploaded_by_name
      final newRecipe = RecipeModel(
        id: '',
        name: nameController.text,
        origin: originController.text,
        short_description: descController.text,
        cooking_time: timeController.text.isEmpty
            ? 'Not specified'
            : timeController.text,
        steps: steps,
        ingredients: ingredients,
        photo: imageController.text.isEmpty
            ? 'https://via.placeholder.com/400x300?text=Recipe+Image'
            : imageController.text,
        uploaded_by: widget.currentUserId,
        favorites_count: 0,
        category_id: getCategoryId(selectedCategory),
      );

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                const Text(
                  "Saving Recipe...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );

      // Save recipe
      final recipeId = await RecipeService().addRecipe(newRecipe);

      // Add recipe to user's recipes list
      await UserService().addRecipeToUser(widget.currentUserId, recipeId);

      // Hide loading
      if (mounted) Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Recipe added successfully!",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Return to previous screen with success flag
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Hide loading if still showing
      if (mounted) Navigator.pop(context);

      _showError("Error adding recipe: $e");
      print('Error saving recipe: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            hintText: hintText ?? label,
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
