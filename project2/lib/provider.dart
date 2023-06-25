import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String name;
  final String category;
  final List<dynamic> favourites;
  final List<dynamic> ingredients;
  final List<dynamic> steps;

  String creator = '';
  Recipe(
      {required this.id,
      required this.name,
      required this.steps,
      required this.ingredients,
      required this.category,
      required this.favourites,
      this.creator = ''});

  factory Recipe.fromFirestore(Map<String, dynamic> data, String id) {
    return Recipe(
        id: id,
        name: data['name'],
        steps: data['steps'],
        ingredients: data['ingredients'],
        category: data['category'],
        favourites: data['favourites'],
        creator: data['creator'] ?? '');
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'steps': steps,
      'ingredients': ingredients,
      'category': category,
      'favourites': favourites,
      'creator': creator
    };
  }
}

final userProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final searchBarProvider = StateProvider<String>((ref) => '');

class RecipeNotifier extends StateNotifier<List<Recipe>> {
  final String userId;
  RecipeNotifier({required this.userId}) : super([]) {
    _fetchRecipe();
  }

  final colRef = FirebaseFirestore.instance.collection('recipes');

  void _fetchRecipe() async {
    final snapshot = await colRef.get();
    final notes = snapshot.docs.map((doc) {
      return Recipe.fromFirestore(doc.data(), doc.id);
    }).toList();

    state = notes;
  }

  int limit = 20;
  DocumentSnapshot? lastDocument;
  bool isFetching = false;
  bool hasMoreData = true;

  void fetchRecipeLimit() async {
    if (!hasMoreData || isFetching) return;

    isFetching = true;

    var query = colRef.orderBy('name').limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      final notes = querySnapshot.docs.map((doc) {
        return Recipe.fromFirestore(doc.data(), doc.id);
      }).toList();
      state = [...state, ...notes];
      if (querySnapshot.docs.length < limit) {
        hasMoreData = false;
      }
    } else {
      hasMoreData = false;
    }

    isFetching = false;
  }

  void addRecipe(String name, List<String> steps, List<String> ingredients,
      String category) async {
    if (userId == '') {
      return;
    }
    final recipeData = Recipe(
            id: '',
            name: name,
            steps: steps,
            ingredients: ingredients,
            category: category,
            favourites: [],
            creator: userId)
        .toFirestore();

    final noteRef = await colRef.add(recipeData);
    final note = Recipe.fromFirestore(recipeData, noteRef.id);
    state = [...state, note];
  }

  void editRecipe(
      String name,
      List<String> steps,
      List<String> ingredients,
      String category,
      List<dynamic> favourites,
      String ids,
      String creator) async {
    if (userId == '' || creator != userId) {
      return;
    }
    final recipeData = Recipe(
            id: '',
            name: name,
            steps: steps,
            ingredients: ingredients,
            category: category,
            favourites: favourites,
            creator: creator)
        .toFirestore();

    await colRef.doc(ids).set(recipeData);
    final noteRef = colRef.doc(ids);
    final note = Recipe.fromFirestore(recipeData, noteRef.id);
    state = state.map((e) => e.id == note.id ? note : e).toList();
  }

  void deleteRecipe(String id, String creator) async {
    if (userId == '' || creator != userId) {
      return;
    }
    await colRef.doc(id).delete();
    state = state.where((note) => note.id != id).toList();
  }

  void updateFavourite(String recipe) async {
    if (userId == '') {
      return;
    }
    final docRef = colRef.doc(recipe);
    final snapshot = await docRef.get();
    final data = snapshot.data();

    if (data != null && data.containsKey('favourites')) {
      if (data['favourites'].contains(userId)) {
        await docRef.update({
          "favourites": FieldValue.arrayRemove([userId])
        });
      } else {
        await docRef.update({
          "favourites": FieldValue.arrayUnion([userId])
        });
      }
    }
  }
}

final recipeProvider =
    StateNotifierProvider<RecipeNotifier, List<Recipe>>((ref) {
  final asyncUser = ref.watch(userProvider);
  return asyncUser.when(data: (user) {
    return RecipeNotifier(userId: user?.uid ?? '');
  }, loading: () {
    return RecipeNotifier(userId: '');
  }, error: (error, stackTrace) {
    return RecipeNotifier(userId: '');
  });
});
