import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/recipe_model.dart';
import '../recipe_page/recipe_page.dart';

class FavoritePage extends StatefulWidget {
  final String userId;
  const FavoritePage({super.key, required this.userId});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final UserService userService = UserService();
  Set<String> favoriteRecipeIds = {};
  List<RecipeModel> favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() {
    userService.getUserFavoriteRecipes(widget.userId).listen((recipes) {
      setState(() {
        favoriteRecipes = recipes;
        favoriteRecipeIds = recipes.map((r) => r.id).toSet();
      });
    });
  }

  Future<void> toggleFavorite(RecipeModel recipe) async {
    if (favoriteRecipeIds.contains(recipe.id)) {
      await userService.removeFavorite(widget.userId, recipe.id);
      setState(() {
        favoriteRecipeIds.remove(recipe.id);
        favoriteRecipes.removeWhere((r) => r.id == recipe.id);
      });
    } else {
      await userService.addFavorite(widget.userId, recipe.id);
      setState(() {
        favoriteRecipeIds.add(recipe.id);
        favoriteRecipes.add(recipe);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorite Recipes")),
      body: favoriteRecipes.isEmpty
          ? const Center(
              child: Text(
                "No favorite recipes yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                final recipe = favoriteRecipes[index];
                final isFav = favoriteRecipeIds.contains(recipe.id);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipePage(recipeId: recipe.id),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          child: Image.network(
                            recipe.photo,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.timer,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          recipe.cooking_time,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await toggleFavorite(recipe);
                                          },
                                          child: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.pinkAccent,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${recipe.favorites_count} Likes",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
