import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'widgets.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/create', builder: (context, state) => CreateScreen(id: '')),
    GoRoute(
        path: '/category', builder: (context, state) => const CategoryScreen()),
    GoRoute(
        path: '/category/:id',
        builder: (context, state) =>
            RecipeListScreen(category: state.pathParameters['id']!)),
    GoRoute(
        path: '/edit/:id',
        builder: (context, state) =>
            CreateScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/my', builder: (context, state) => const MyRecipeScreen()),
    GoRoute(
        path: '/favourites',
        builder: (context, state) => const FavouritesScreen()),
    GoRoute(
        path: '/recipe/:name',
        builder: (context, state) =>
            RecipeScreen(name: state.pathParameters['name']!)),
  ],
);

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MaterialApp.router(routerConfig: router)));
}
