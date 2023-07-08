import 'package:consultorio_terapeutico_gestaltico/models/category.dart';
import 'package:consultorio_terapeutico_gestaltico/models/service.dart';
import 'package:consultorio_terapeutico_gestaltico/pages/booking_page.dart';
import 'package:consultorio_terapeutico_gestaltico/providers/services_provider.dart';
import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();

    () async {
      await Future.delayed(Duration.zero);
      final servicesProvider = Provider.of<ServicesProvider>(
        context,
        listen: false,
      );

      if (servicesProvider.categories.isEmpty) {
        servicesProvider.loadCategories();
      }
    }();

    getButton();
  }

  User? user;
  String? Admin;

  bool hasUser = false;

  void getButton() async {
    ApiResponse response = await getUserDetail();
    User? user = response.data as User?;

    if (user != null) {
      setState(() {
        hasUser = true;
      });
      print('Hay un usuario cargado');
    } else {
      setState(() {
        hasUser = false;
      });
      print('No hay un usuario cargado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesProvider = Provider.of<ServicesProvider>(context);

    return Scaffold(
      body: servicesProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Utils.secondaryColor,
                ),
              ),
            )
          : const Stack(
              children: [
                _PageViewCategories(),
                _WhiteBox(),
                //            Positioned(
                //             bottom: 20.0,
                //            left: 0,
                //            right: 0,
                //         child:
                //            hasUser ? UserLoggedInWidget() : buildLoginPageButton(),
                //           ),
              ],
            ),
    );
  }

/* Widget buildLoginPageButton() {
    return ElevatedButton(
      onPressed: () {
        print('Botón de inicio de sesión presionado');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            Utils.secondaryColor), // Cambia el color de fondo aquí
      ),
      child: const Text('Iniciar sesión'),
    );
  } */
}

class UserLoggedInWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtén el nombre de usuario según corresponda
    final userName = "";

    return Text('$userName');
  }
}

class _PageViewCategories extends StatefulWidget {
  const _PageViewCategories({Key? key}) : super(key: key);

  @override
  __PageViewCategoriesState createState() => __PageViewCategoriesState();
}

class __PageViewCategoriesState extends State<_PageViewCategories> {
  @override
  void dispose() {
    final servicesProvider = Provider.of<ServicesProvider>(
      context,
      listen: false,
    );
    servicesProvider.pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesProvider = Provider.of<ServicesProvider>(context);
    servicesProvider.pageController = PageController(initialPage: 0);

    return PageView.builder(
      physics: const NeverScrollableScrollPhysics(),
      controller: servicesProvider.pageController,
      itemCount: servicesProvider.categories.length,
      itemBuilder: (_, int index) {
        return _CategoryPageView(
          path: servicesProvider.categories[index].photo,
        );
      },
    );
  }
}

class _WhiteBox extends StatelessWidget {
  const _WhiteBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final servicesProvider = Provider.of<ServicesProvider>(context);
    final size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: size.height * 0.70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 120.0,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white,
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: RefreshIndicator(
                  color: Utils.primaryColor,
                  onRefresh: () => servicesProvider.loadCategories(),
                  child: const _HomeServices(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeServices extends StatelessWidget {
  const _HomeServices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final servicesProvider = Provider.of<ServicesProvider>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Servicios',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 20.0),
            _CategoriesCarousel(
              categories: servicesProvider.categories,
            ),
            const SizedBox(height: 20.0),
            servicesProvider.category == null
                ? const Text('Seleccione primero una categoría.')
                : _ServicesList(
                    services: servicesProvider.category!.services,
                  ),
          ],
        ),
      ),
    );
  }
}

class _ServicesList extends StatelessWidget {
  const _ServicesList({
    Key? key,
    required this.services,
  }) : super(key: key);

  final List<Service> services;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemBuilder: (_, int index) {
          Service service = services[index];
          return ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(
                BookingPage.route,
                arguments: service,
              );
            },
            title: Text(service.name),
            /**trailing: Text(
                "\$${service.price}",
                style: const TextStyle(color: Utils.grayColor),
                ),**/
          );
        },
        separatorBuilder: (_, int index) {
          return const Divider(
            color: Utils.grayColor,
          );
        },
        itemCount: services.length,
      ),
    );
  }
}

class _CategoriesCarousel extends StatelessWidget {
  const _CategoriesCarousel({
    Key? key,
    required this.categories,
  }) : super(key: key);

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final servicesProvider = Provider.of<ServicesProvider>(context);

    return SizedBox(
      height: 110.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (_, int index) {
          Category category = categories[index];

          final categoryItem = _CategoryItem(
            icon: servicesProvider.icons[category.icon]!,
            label: category.name,
            isSelected: servicesProvider.category?.id == category.id,
            onTap: () => servicesProvider.selectCategory(category),
          );

          if (index == 0) {
            return Row(
              children: [
                const SizedBox(width: 10.0),
                categoryItem,
              ],
            );
          }
          if (index == categories.length - 1) {
            return Row(
              children: [
                categoryItem,
                const SizedBox(width: 20.0),
              ],
            );
          }
          return categoryItem;
        },
        separatorBuilder: (_, int index) {
          return const SizedBox(width: 15.0);
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Utils.secondaryColor : Utils.primaryColor,
            ),
            child: Icon(
              icon,
              size: 35.0,
              color: isSelected ? Colors.white : Utils.secondaryColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}

class _CategoryPageView extends StatelessWidget {
  const _CategoryPageView({
    Key? key,
    required this.path,
  }) : super(key: key);

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: FadeInImage(
        placeholder: const AssetImage('assets/haircut.jpg'),
        image: NetworkImage(path),
        fit: BoxFit.contain,
        width: double.infinity,
      ),
    );
  }
}
