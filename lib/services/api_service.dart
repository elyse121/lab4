import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  final String baseUrl = "https://jsonplaceholder.typicode.com/posts";

  // ✅ FETCH POSTS (FIXED FOR EMULATOR)
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Accept": "application/json"},
      );

      print("STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("ERROR: $e");
      throw Exception("Failed to load posts");
    }
  }

  // ✅ CREATE POST
  Future<void> createPost(Post post) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(post.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to create post");
      }
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  // ✅ UPDATE POST
  Future<void> updatePost(Post post) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/${post.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(post.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update post");
      }
    } catch (e) {
      throw Exception("Error updating post: $e");
    }
  }

  // ✅ DELETE POST
  Future<void> deletePost(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$id"));

      if (response.statusCode != 200) {
        throw Exception("Failed to delete post");
      }
    } catch (e) {
      throw Exception("Error deleting post: $e");
    }
  }
}
