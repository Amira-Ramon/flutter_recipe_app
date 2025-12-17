import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../models/category_model.dart';
import '../../services/recipe_service.dart';
import '../../services/user_service.dart';
import '../../services/category_service.dart';
import '../../services/auth_service.dart';

import '../profile_page/profile_page.dart';
import '../recipe_page/recipe_page.dart';
import '../favorite_page/favorite_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  final Color primaryColor = const Color(0xFF1EAE98);

  final RecipeService recipeService = RecipeService();
  final UserService userService = UserService();
  final CategoryService categoryService = CategoryService();

  final TextEditingController searchController = TextEditingController();

  String? currentUserId;

  List<RecipeModel> recipes = [];
  List<RecipeModel> filteredRecipes = [];
  List<RecipeModel> popularRecipes = [];

  List<CategoryModel> categories = [];
  String selectedCategory = "All";
  Set<String> favoriteRecipeIds = {};

  @override
  void initState() {
    super.initState();

    final uid = AuthService().currentUid;

    if (uid == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    currentUserId = uid;

    fetchRecipes();
    fetchCategories();
    loadUserFavorites();
  }

  void loadUserFavorites() {
    if (currentUserId == null) return;

    userService.getUserById(currentUserId!).then((user) {
      if (user != null) {
        setState(() {
          favoriteRecipeIds = user.favorites.toSet();
        });
      }
    });
  }

  Future<void> toggleFavorite(String recipeId) async {
    if (currentUserId == null) return;
    await userService.toggleFavorite(currentUserId!, recipeId);

    setState(() {
      if (favoriteRecipeIds.contains(recipeId)) {
        favoriteRecipeIds.remove(recipeId);
      } else {
        favoriteRecipeIds.add(recipeId);
      }

      final recipeIndex = recipes.indexWhere((r) => r.id == recipeId);
      if (recipeIndex != -1) {
        if (favoriteRecipeIds.contains(recipeId)) {
          recipes[recipeIndex].favorites_count++;
        } else {
          recipes[recipeIndex].favorites_count =
              (recipes[recipeIndex].favorites_count > 0)
              ? recipes[recipeIndex].favorites_count - 1
              : 0;
        }
      }
    });
  }

  void fetchCategories() {
    categoryService.getAllCategories().listen((fetchedCategories) {
      setState(() {
        categories = [CategoryModel(id: "All", name: "All", photo: "")];
        categories.addAll(fetchedCategories);
      });
    });
  }

  void fetchRecipes() {
    recipeService.getAllRecipes().listen((fetchedRecipes) {
      setState(() {
        recipes = fetchedRecipes;
        filterRecipes(selectedCategory);

        popularRecipes =
            fetchedRecipes.where((r) => r.favorites_count > 0).toList()
              ..sort((a, b) => b.favorites_count.compareTo(a.favorites_count));
        popularRecipes = popularRecipes.take(6).toList();
      });
    });
  }

  void searchRecipes(String query) {
    final recipesToSearch = selectedCategory == "All"
        ? recipes
        : recipes.where((r) => r.category_id == selectedCategory).toList();

    final results = recipesToSearch.where((r) {
      return r.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredRecipes = results;
    });
  }

  void filterRecipes(String categoryId) {
    setState(() {
      selectedCategory = categoryId;
      searchController.clear();

      filteredRecipes = categoryId == "All"
          ? recipes
          : recipes.where((r) => r.category_id == categoryId).toList();
    });
  }

  Widget _buildCategoryButton(CategoryModel category) {
    final bool isSelected = selectedCategory == category.id;

    return GestureDetector(
      onTap: () => filterRecipes(category.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category.name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget buildRecipeCard(RecipeModel recipe) {
    final bool isFav = favoriteRecipeIds.contains(recipe.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipePage(recipeId: recipe.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              child: Image.network(
                recipe.photo,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 14, color: Colors.grey),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => toggleFavorite(recipe.id),
                        child: AnimatedScale(
                          scale: isFav ? 1.3 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.pinkAccent,
                            size: 22,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          Text(
                            "${recipe.favorites_count} Likes",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "what are you cooking today? 💚",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        hintText: "Search recipe",
                      ),
                      onChanged: searchRecipes,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories
                    .map((cat) => _buildCategoryButton(cat))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 260,
              child: filteredRecipes.isEmpty
                  ? const Center(
                      child: Text(
                        "No recipes found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        return buildRecipeCard(filteredRecipes[index]);
                      },
                    ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Popular Recipes ⭐",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: popularRecipes.length,
                itemBuilder: (context, index) {
                  return buildRecipeCard(popularRecipes[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          if (index == currentIndex) return;

          if (index == 1) {
            setState(() {
              currentIndex = 1;
            });
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritePage(userId: currentUserId!),
              ),
            );
            setState(() {
              currentIndex = 0;
            });
          } else if (index == 2) {
            setState(() {
              currentIndex = 2;
            });
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(currentUserId: currentUserId!),
              ),
            );
            setState(() {
              currentIndex = 0;
            });
          } else {
            setState(() {
              currentIndex = 0;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
