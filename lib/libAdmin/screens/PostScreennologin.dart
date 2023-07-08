import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../utils/utils.dart';

class PostScreennologin extends StatefulWidget {
  const PostScreennologin({Key? key}) : super(key: key);

  @override
  _PostScreennologinState createState() => _PostScreennologinState();
}

class _PostScreennologinState extends State<PostScreennologin> {
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response =
        await http.get(Uri.parse('http://34.171.207.241/proyecto1/api/postsnologin/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _posts = data['posts'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novedades'),
        backgroundColor: Utils.primaryColor,
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Deshabilitar la flecha para volver atrás
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            elevation: 4,
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(post['user']['image']),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(post['user']['name']),
                    ),
                  ],
                ),
                VerticalDivider(), // Línea de separación vertical
                ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['body']),

                      SizedBox(width: 10),
                      // Espacio horizontal entre el Divider y el Text

                      if (post['image'] != null)
                        Image.network(
                          post['image'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite),
                          Text(post['likes_count'].toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
