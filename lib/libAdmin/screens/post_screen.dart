import 'package:flutter/material.dart';
import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/post.dart';
import '../../screens/comment_screen.dart';
import '../../screens/loading.dart';
import '../../services/post_service.dart';
import '../../services/user_service.dart';
import '../../utils/utils.dart';
import '../../screens/login.dart';
import 'post_form.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> _postList = [];
  int userId = 0;
  bool _loading = true;

  // get all posts
  Future<void> retrievePosts() async {
    userId = await getUserId();
    ApiResponse response = await getPosts();

    if (response.error == null) {
      setState(() {
        _postList = response.data as List<dynamic>;
        _loading = _loading ? !_loading : _loading;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
    }
  }

  void _handleDeletePost(int postId) async {
    ApiResponse response = await deletePost(postId);
    if (response.error == null) {
      setState(() {
        _loading = true;
      });
      await retrievePosts();
      setState(() {
        _loading = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Loading()));
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // post like dislik
  void _handlePostLikeDislike(int postId) async {
    ApiResponse response = await likeUnlikePost(postId);

    if (response.error == null) {
      retrievePosts();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.network(imageUrl),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    retrievePosts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(
            child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Utils.secondaryColor)))
        : RefreshIndicator(
            onRefresh: () {
              return retrievePosts();
            },
            child: ListView.builder(
                itemCount: _postList.length,
                itemBuilder: (BuildContext context, int index) {
                  Post post = _postList[index];
                  return Card(
                    elevation: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          // decoracion de imagen del post
                                          image: post.user!.image != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      '${post.user!.image}'))
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                        '${post.user!.name}', //Nomre sobre la imagen
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17))
                                  ],
                                ),
                              ),
                              post.user!.id == userId
                                  ? PopupMenuButton(
                                      child: const Padding(
                                          padding: EdgeInsets.only(right: 12),
                                          child: Icon(
                                            Icons.more_vert,
                                            color: Colors.black,
                                          )),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                            value: 'edit', child: Text('Edit')),
                                        const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Borrar'))
                                      ],
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PostForm(
                                                        title: 'Editar Post',
                                                        post: post,
                                                      )));
                                        } else {
                                          _handleDeletePost(post.id ?? 0);
                                        }
                                      },
                                    )
                                  : const SizedBox()
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text('${post.body}'),
                          post.image != null
                              ? GestureDetector(
                                  onTap: () {
                                    if (post.image != null) {
                                      _showImageDialog(post.image!);
                                    }
                                  },
                                  child: post.image != null
                                      ? Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 200,
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage('${post.image}'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          height: post.image != null ? 0 : 10,
                                        ),
                                )
                              : SizedBox(
                                  height: post.image != null ? 0 : 10,
                                ),
                          Row(
                            children: [
                              kLikeAndComment(
                                  post.likesCount ?? 0,
                                  post.selfLiked == true
                                      ? Icons.favorite
                                      : Icons.favorite_outline,
                                  post.selfLiked == true
                                      ? Colors.red
                                      : Colors.black54, () {
                                _handlePostLikeDislike(post.id ?? 0);
                              }),
                              Container(
                                height: 30,
                                width: 0.5,
                                color: Colors.black38,
                              ),
                              kLikeAndComment(post.commentsCount ?? 0,
                                  Icons.sms_outlined, Colors.black54, () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => CommentScreen(
                                          postId: post.id,
                                        )));
                              }),
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 0.5,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          );
  }
}
