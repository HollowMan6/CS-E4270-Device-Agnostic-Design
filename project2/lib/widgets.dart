import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'provider.dart';

class AppBarWidget extends ConsumerWidget {
  final dynamic body;
  final TextEditingController _searchController = TextEditingController();
  AppBarWidget({super.key, required this.body});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serch = ref.watch(searchBarProvider);
    final loggedIn = ref.watch(userProvider).value != null;
    dynamic res;
    if (serch == '') {
      res = body;
    } else {
      res = const SearchWidget();
    }
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text("Recipes"),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => {
                          ref
                              .watch(searchBarProvider.notifier)
                              .update((state) => value)
                        }),
              ),
            ],
          ),
          actions: [
            if (loggedIn && width > 600) ...[
              ElevatedButton(
                  onPressed: () => context.go('/my'),
                  child: const Text("My Recipes")),
              ElevatedButton(
                  onPressed: () => context.go('/favourites'),
                  child: const Text("Favourites")),
              ElevatedButton(
                  onPressed: () => context.go('/create'),
                  child: const Text("Create Recipe")),
            ],
            if (loggedIn && width <= 600)
              PopupMenuButton(itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text("My Recipes"),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text("Favourites"),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text("Create Recipe"),
                  ),
                ];
              }, onSelected: (value) {
                if (value == 0) {
                  context.go('/my');
                } else if (value == 1) {
                  context.go('/favourites');
                } else if (value == 2) {
                  context.go('/create');
                }
              }),
            ElevatedButton(
                onPressed: () => {
                      loggedIn
                          ? FirebaseAuth.instance.signOut()
                          : FirebaseAuth.instance.signInAnonymously(),
                    },
                child: loggedIn ? const Text("Log Out") : const Text("Log In")),
          ],
        ),
        body: res,
        bottomNavigationBar: const BottomNavigationBarWidget());
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomNavigationbar();
  }
}

class BottomNavigationbar extends StatefulWidget {
  const BottomNavigationbar({super.key});

  @override
  State<BottomNavigationbar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavigationbar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_list),
          label: 'Category',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.question_mark),
          label: 'Random',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.grey[600],
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/category');
            break;
          case 2:
            context.go('/recipe/random');
            break;
        }
      },
    );
  }
}

class SearchWidget extends ConsumerWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBarText = ref.watch(searchBarProvider);
    final recipes = ref.watch(recipeProvider);
    final lst = recipes
        .where((element) =>
            element.name.toLowerCase().contains(searchBarText.toLowerCase()))
        .map((e) => Card(
            child: GestureDetector(
                onTap: () => {
                      ref
                          .watch(searchBarProvider.notifier)
                          .update((state) => ''),
                      context.go("/recipe/${e.name}")
                    },
                child: ListTile(
                  title: Text(e.name),
                  subtitle: Text(e.category),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ))))
        .toList();
    return ListView(
        children: lst.isEmpty
            ? [
                const Card(
                    child: ListTile(
                  title: Text("No Matches"),
                ))
              ]
            : lst);
  }
}

List<Color> colors = [
  Colors.redAccent,
  Colors.orange,
  Colors.amber,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipeProvider);
    int count = MediaQuery.of(context).size.width ~/ 240;
    count < 1 ? 1 : count;
    final categories = recipes
        .map((e) => e.category)
        .toSet()
        .toList()
        .map((e) => GestureDetector(
              onTap: () => context.go("/category/$e"),
              child: Card(
                  child: Column(
                children: [
                  const Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(8), child: Placeholder())),
                  ListTile(
                    title: Text(e),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  )
                ],
              )),
            ))
        .toList();
    final categoryGrid = GridView.count(
      crossAxisCount: count,
      children: categories,
    );
    return AppBarWidget(body: Center(child: categoryGrid));
  }
}

class CreateScreen extends ConsumerWidget {
  final String id;
  final ingredientController = TextEditingController();
  final stepController = TextEditingController();
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final ingredientProvider = StateProvider<List<String>>((ref) => []);
  final stepProvider = StateProvider<List<String>>((ref) => []);
  final nameProvider = StateProvider<String>((ref) => '');
  final categoryProvider = StateProvider<String>((ref) => '');

  CreateScreen({super.key, required this.id});

  _addIngr(WidgetRef ref) {
    ref
        .watch(ingredientProvider.notifier)
        .update((state) => [...state, ingredientController.text]);
    ingredientController.clear();
  }

  _deleteIngr(WidgetRef ref, String ingr) {
    ref.watch(ingredientProvider.notifier).update((state) =>
        state.where((element) => element != ingr).toList(growable: false));
  }

  _addStep(WidgetRef ref) {
    ref
        .watch(stepProvider.notifier)
        .update((state) => [...state, stepController.text]);
    stepController.clear();
  }

  _deleteStep(WidgetRef ref, String step) {
    ref.watch(stepProvider.notifier).update((state) =>
        state.where((element) => element != step).toList(growable: false));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = (ref.watch(nameProvider) != '') &&
        (ref.watch(categoryProvider) != '') &&
        (ref.watch(stepProvider).isNotEmpty) &&
        (ref.watch(ingredientProvider).isNotEmpty);
    final loggedIn = ref.watch(userProvider).value != null;
    if (!loggedIn) {
      return AppBarWidget(
          body: const Text('You need to be logged in to create a recipe'));
    }
    final editedRecipe = id != ''
        ? ref
            .watch(recipeProvider)
            .firstWhereOrNull((element) => element.id == id)
        : null;
    if (id != '' && editedRecipe == null) {
      return AppBarWidget(body: const Text('Recipe not found'));
    }

    if (editedRecipe != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (nameController.text == '') {
          nameController.text = editedRecipe.name;
        }
        if (categoryController.text == '') {
          categoryController.text = editedRecipe.category;
        }
        ref.read(nameProvider.notifier).update((state) {
          if (state == '') {
            nameController.text = editedRecipe.name;
            return editedRecipe.name;
          }
          return state;
        });
        ref.read(categoryProvider.notifier).update((state) {
          if (state == '') {
            categoryController.text = editedRecipe.category;
            return editedRecipe.category;
          }
          return state;
        });
        ref.read(ingredientProvider.notifier).update((state) {
          if (state.isEmpty) {
            return editedRecipe.ingredients.map((e) => e as String).toList();
          }
          return state;
        });
        ref.read(stepProvider.notifier).update((state) {
          if (state.isEmpty) {
            return editedRecipe.steps.map((e) => e as String).toList();
          }
          return state;
        });
      });
    }

    return AppBarWidget(
        body: Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(children: [
        const Text("Recipe name:", style: TextStyle(fontSize: 20)),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (value) => ref
              .watch(nameProvider.notifier)
              .update((state) => nameController.text),
        ),
        const Text("Category name:", style: TextStyle(fontSize: 20)),
        TextField(
          controller: categoryController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (value) => ref
              .watch(categoryProvider.notifier)
              .update((state) => categoryController.text),
        ),
        const Text("Ingredients:", style: TextStyle(fontSize: 20)),
        Column(children: [
          TextField(
            controller: ingredientController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          ElevatedButton(
              onPressed: () => ingredientController.value.text.isNotEmpty
                  ? _addIngr(ref)
                  : null,
              child: const Text('+1')),
          ...ref
              .watch(ingredientProvider)
              .map((e) => Card(
                  child: ListTile(
                      title: Text(e),
                      trailing: IconButton(
                          onPressed: () => _deleteIngr(ref, e),
                          icon: const Icon(Icons.delete)))))
              .toList()
        ]),
        const Text("Steps:", style: TextStyle(fontSize: 20)),
        Column(children: [
          TextField(
            controller: stepController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          ElevatedButton(
              onPressed: () =>
                  stepController.value.text.isNotEmpty ? _addStep(ref) : null,
              child: const Text('+1')),
          ...ref
              .watch(stepProvider)
              .map((e) => Card(
                  child: ListTile(
                      title: Text(
                          "Step ${ref.watch(stepProvider).indexOf(e) + 1}"),
                      subtitle: Text(e),
                      trailing: IconButton(
                          onPressed: () => _deleteStep(ref, e),
                          icon: const Icon(Icons.delete)))))
              .toList()
        ]),
        !done
            ? const Center(
                child:
                    Text("Finish all the fields above to create a recipe..."))
            : ElevatedButton(
                onPressed: () => {
                      editedRecipe == null
                          ? ref.watch(recipeProvider.notifier).addRecipe(
                                ref.watch(nameProvider),
                                ref.watch(stepProvider),
                                ref.watch(ingredientProvider),
                                ref.watch(categoryProvider),
                              )
                          : ref.watch(recipeProvider.notifier).editRecipe(
                              ref.watch(nameProvider),
                              ref.watch(stepProvider),
                              ref.watch(ingredientProvider),
                              ref.watch(categoryProvider),
                              editedRecipe.favourites,
                              editedRecipe.id,
                              editedRecipe.creator),
                      ref
                          .watch(ingredientProvider.notifier)
                          .update((state) => []),
                      ref.watch(stepProvider.notifier).update((state) => []),
                      ref.watch(nameProvider.notifier).update((state) => ''),
                      ref
                          .watch(categoryProvider.notifier)
                          .update((state) => ''),
                      context.go('/')
                    },
                child: editedRecipe == null
                    ? const Text("Create!")
                    : const Text("Edit!"))
      ]),
    ));
  }
}

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    ref.watch(userProvider).value != null;
    if (user.value == null) {
      return AppBarWidget(
          body: const Text(
              'You need to be logged in to see your favourite recipes'));
    }
    final userRecipes = ref
        .watch(recipeProvider)
        .where((element) => element.favourites.contains(user.value?.uid))
        .toList();
    final list = userRecipes.map(
      (e) => Expanded(
          child: GestureDetector(
              onTap: () => context.go('/recipe/${e.name}'),
              child: Card(
                child: ListTile(
                  title: Text(e.name),
                  subtitle: Text(e.category),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ))),
    );
    dynamic res;
    if (list.isEmpty) {
      res = [const Text("No favourite recipes")];
    } else {
      res = list;
    }
    return AppBarWidget(
        body: ListView(
      children: [...res],
    ));
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipeProvider);
    final featuredRecipeWidget = recipes
        .map((e) => Card(
              child: GestureDetector(
                onTap: () => {context.go("/recipe/${e.name}")},
                child: ListTile(
                  title: Text(e.name),
                  subtitle: Text(e.category),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ))
        .take(2)
        .toList();

    double count = MediaQuery.of(context).size.height / 20;
    final categories = recipes
        .map((e) => e.category)
        .toSet()
        .toList()
        .map((e) => GestureDetector(
              onTap: () => {
                context.go("/category/$e"),
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                color: colors[
                    recipes.map((e) => e.category).toList().indexOf(e) % 7],
                height: count,
                child: Card(
                  child: Center(
                    child: Text(e),
                  ),
                ),
              ),
            ))
        .toList();
    var itemCount = 20 < categories.length ? 20 : categories.length;

    final scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        itemCount = itemCount + 20 < categories.length
            ? itemCount + 20
            : categories.length;
      }
    });

    return AppBarWidget(
      body: Column(
        children: [
          Text(
            "Featured Recipe",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ...featuredRecipeWidget,
          Text(
            "Categories",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: itemCount + 1,
              itemBuilder: (context, index) {
                if (index < itemCount) {
                  return categories[index];
                } else {
                  if (itemCount != categories.length || itemCount == 0) {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyRecipeScreen extends ConsumerWidget {
  const MyRecipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user.value == null) {
      return AppBarWidget(
          body: const Text(
              'You need to be logged in to see the recipes you created'));
    }
    final userRecipes = ref
        .watch(recipeProvider)
        .where((element) => element.creator == user.value?.uid)
        .toList();
    final list = userRecipes.map((e) => Row(
          children: [
            Expanded(
                child: GestureDetector(
                    onTap: () => context.go('/recipe/${e.name}'),
                    child: Card(
                      child: ListTile(
                          title: Text(e.name),
                          subtitle: Text(e.category),
                          trailing: const Icon(Icons.arrow_forward_ios)),
                    ))),
            IconButton(
                onPressed: () => {
                      context.go('/edit/${e.id}'),
                    },
                icon: const Icon(Icons.edit)),
            IconButton(
                onPressed: () => ref
                    .watch(recipeProvider.notifier)
                    .deleteRecipe(e.id, e.creator),
                icon: const Icon(Icons.delete)),
          ],
        ));
    dynamic res;
    if (list.isEmpty) {
      res = [const Expanded(child: Text("No created recipes"))];
    } else {
      res = list;
    }
    return AppBarWidget(
        body: ListView(
      children: [...res],
    ));
  }
}

class RecipeListScreen extends ConsumerWidget {
  final String category;
  const RecipeListScreen({super.key, required this.category});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipeProvider).toSet().toList();
    int count = MediaQuery.of(context).size.width ~/ 240;
    count = count < 1 ? 1 : count;
    final recipeList = recipes
        .where((element) => element.category == category)
        .map((e) => GestureDetector(
            onTap: () => {
                  context.go("/recipe/${e.name}"),
                },
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Card(
                child: Column(children: [
                  ListTile(
                    title: Text(e.name),
                    subtitle: Text(e.category),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  const Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(20), child: Placeholder())),
                  ListTile(
                      title: IconButton(
                        onPressed: () => {
                          ref
                              .watch(recipeProvider.notifier)
                              .updateFavourite(e.id),
                          ref.refresh(recipeProvider),
                        },
                        icon: const Icon(Icons.favorite_rounded),
                      ),
                      subtitle: Center(child: Text("${e.favourites.length}"))),
                ]),
              ),
            )))
        .toList();
    final categoryGrid = GridView.count(
      crossAxisCount: count,
      children: recipeList,
    );
    return AppBarWidget(body: categoryGrid);
  }
}

class RecipeScreen extends ConsumerWidget {
  final String name;
  const RecipeScreen({super.key, required this.name});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Recipe recipe;
    Recipe? fetchedRecipe;
    if (name == 'random') {
      final mix = ref.watch(recipeProvider);
      fetchedRecipe =
          (mix.toList()..shuffle()).take(1).firstWhereOrNull((element) => true);
    } else {
      fetchedRecipe = ref
          .watch(recipeProvider)
          .firstWhereOrNull((element) => element.name == name);
    }
    if (fetchedRecipe == null) {
      return AppBarWidget(body: const Text('Loading...'));
    }
    recipe = fetchedRecipe;
    final stepWidget = recipe.steps
        .map((e) => Card(
                child: ListTile(
              title: Text("Step ${recipe.steps.indexOf(e) + 1}"),
              subtitle: Text(e),
            )))
        .toList();
    final ingredients = recipe.ingredients
        .map((e) => Card(child: ListTile(title: Text(e))))
        .toList();

    return AppBarWidget(
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Center(
                    child: Text(recipe.name,
                        style: const TextStyle(fontSize: 30))),
                const Center(
                    child: SizedBox(
                        width: 600, height: 250, child: Placeholder())),
                const Text("", style: TextStyle(fontSize: 20)),
                ListTile(
                  title: IconButton(
                    onPressed: () => {
                      ref
                          .watch(recipeProvider.notifier)
                          .updateFavourite(recipe.id),
                      ref.refresh(recipeProvider),
                    },
                    icon: const Icon(Icons.favorite_rounded),
                  ),
                  subtitle: Center(child: Text("${recipe.favourites.length}")),
                ),
                const Text("", style: TextStyle(fontSize: 20)),
                const Text("Ingredients:", style: TextStyle(fontSize: 20)),
                ...ingredients,
                const Text("", style: TextStyle(fontSize: 20)),
                const Text(
                  "Steps:",
                  style: TextStyle(fontSize: 20),
                ),
                ...stepWidget,
              ],
            )));
  }
}
