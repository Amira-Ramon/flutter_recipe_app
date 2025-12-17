import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';

class RecipePage extends StatefulWidget {
  final String recipeId;

  const RecipePage({super.key, required this.recipeId});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final RecipeService recipeService = RecipeService();
  RecipeModel? recipe;
  bool isLoading = true;
  bool isIngredientsSelected = true;
  List<String> procedureSteps = [];

  @override
  void initState() {
    super.initState();
    fetchRecipe();
  }

  void fetchRecipe() async {
    final fetchedRecipe = await recipeService.getRecipeById(widget.recipeId);
    if (fetchedRecipe != null) {
      setState(() {
        recipe = fetchedRecipe;

        procedureSteps = fetchedRecipe.steps.isNotEmpty
            ? fetchedRecipe.steps
            : [
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                "Step 2: Prepare ingredients.",
                "Final step: Cook and serve."
              ];

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  _buildRecipeTitleAndTime(),
                  const SizedBox(height: 15),
                  _buildOrigin(recipe!.origin),
                  const SizedBox(height: 25),
                  _buildTabsSection(),
                  const SizedBox(height: 10),
                  isIngredientsSelected
                      ? _buildIngredientsList()
                      : _buildProcedureSteps(),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.network(
            recipe!.photo,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 250,
              color: Colors.grey[200],
              child: const Center(child: Text("Loading...")),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeTitleAndTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            recipe!.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Row(
          children: [
            const Icon(Icons.timer, color: Colors.grey, size: 20),
            const SizedBox(width: 4),
            Text(
              recipe!.cooking_time,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrigin(String origin) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.grey, size: 16),
        const SizedBox(width: 6),
        Text(
          origin,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTabsSection() {
    return Row(
      children: [
        _buildTabButton(
          label: "Ingredients",
          isSelected: isIngredientsSelected,
          onTap: () {
            setState(() => isIngredientsSelected = true);
          },
        ),
        _buildTabButton(
          label: "Procedure",
          isSelected: !isIngredientsSelected,
          onTap: () {
            setState(() => isIngredientsSelected = false);
          },
        ),
      ],
    );
  }

  Widget _buildTabButton(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
            left: label == "Ingredients" ? 0 : 8,
            right: label == "Procedure" ? 0 : 8),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1EAE98) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: isSelected ? null : Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...recipe!.ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildIngredientCard(
              name: ingredient.item,
              amount: ingredient.quantity,
            ),
          );
        })
      ],
    );
  }

  Widget _buildProcedureSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(procedureSteps.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildStepCard(
              stepNumber: index + 1,
              description: procedureSteps[index],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIngredientCard({required String name, required String amount}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.fastfood, size: 30, color: Color(0xFF1EAE98)),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({required int stepNumber, required String description}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Step $stepNumber",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
