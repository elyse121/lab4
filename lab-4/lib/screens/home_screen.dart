import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();
  late Future<List<Post>> posts;

  List<Post> localPosts = [];

  @override
  void initState() {
    super.initState();
    posts = api.fetchPosts();
  }

  // ➕ ADD / ✏️ EDIT POST
  void _openPostDialog({Post? post}) {
    final titleController = TextEditingController(text: post?.title ?? '');
    final bodyController = TextEditingController(text: post?.body ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(post == null ? "Add Post" : "Edit Post"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: "Body"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || bodyController.text.isEmpty)
                return;

              setState(() {
                if (post == null) {
                  // CREATE
                  localPosts.insert(
                    0,
                    Post(
                      id: DateTime.now().millisecondsSinceEpoch,
                      userId: 1,
                      title: titleController.text,
                      body: bodyController.text,
                    ),
                  );
                } else {
                  // UPDATE
                  post.title = titleController.text;
                  post.body = bodyController.text;
                }
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // 🗑 DELETE POST
  void _deletePost(int index) {
    setState(() {
      localPosts.removeAt(index);
    });
  }

  // 📄 DETAILS VIEW
  void _openDetails(Post post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(post.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Post ID: ${post.id}"),
            Text("User ID: ${post.userId}"),
            const SizedBox(height: 10),
            Text(post.body),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Posts Manager"),
        centerTitle: true,
        elevation: 2,
      ),

      // ➕ BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPostDialog(),
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<Post>>(
        future: posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final apiPosts = snapshot.data ?? [];
          final allPosts = [...localPosts, ...apiPosts];

          return ListView.builder(
            itemCount: allPosts.length,
            itemBuilder: (context, index) {
              final post = allPosts[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🟦 TITLE
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 🟨 IDS
                        Row(
                          children: [
                            Chip(label: Text("ID: ${post.id}")),
                            const SizedBox(width: 8),
                            Chip(label: Text("User: ${post.userId}")),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 📝 BODY
                        Text(
                          post.body,
                          style: const TextStyle(color: Colors.black87),
                        ),

                        const SizedBox(height: 10),

                        // 🔘 ACTIONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.teal,
                              ),
                              onPressed: () => _openDetails(post),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openPostDialog(post: post),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (index < localPosts.length) {
                                  _deletePost(index);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
