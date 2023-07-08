import 'package:consultorio_terapeutico_gestaltico/pages/booking_page.dart';
import 'package:consultorio_terapeutico_gestaltico/pages/finish_page.dart';
import 'package:consultorio_terapeutico_gestaltico/pages/home_page.dart';
import 'package:consultorio_terapeutico_gestaltico/providers/booking_provider.dart';
import 'package:consultorio_terapeutico_gestaltico/providers/services_provider.dart';
import 'package:consultorio_terapeutico_gestaltico/screens/home.dart';
import 'package:consultorio_terapeutico_gestaltico/screens/loading.dart';
import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'libAdmin/screens/homenologin.dart';

Future<void> _firebaseMessagingBackroundHandler(RemoteMessage message) async {
  print('Handling a backround message ${message.messageId}');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> getmenssaje() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("..OnMessage..");
    print(
        "onMessage: ${message.notification!.title}/${message.notification?.body}");

    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title.toString(),
      htmlFormatSummaryText: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dbfood',
      'dbfood',
      importance: Importance.high,
      styleInformation: bigTextStyleInformation,
      priority: Priority.high,
      playSound: true,
      //    sound: RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const IOSNotificationDetails());
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data['body'],
    );
  });
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    //   'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  initState();

  runApp(const App());
}

void initState() {
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification!.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                  channel.id, channel.name, // channel.description,
                  color: Colors.blue,
                  playSound: true,
                  icon: '@mipmap/ic_launcher'),
            ));
      }
    },
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider())
      ],
      child: MaterialApp(
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
        supportedLocales: const [Locale('en'), Locale('Us')],
        title: 'Agenda App',
        debugShowCheckedModeBanner: false,
        initialRoute: Loading.route,
        theme: ThemeData.light().copyWith(
          primaryColor: Utils.primaryColor,
          textTheme: ThemeData.light().textTheme.copyWith(
                bodyText1: ThemeData.light().textTheme.bodyText1?.copyWith(
                      color: Utils.secondaryColor,
                    ),
                bodyText2: ThemeData.light().textTheme.bodyText1?.copyWith(
                      color: Utils.secondaryColor,
                    ),
                subtitle1: ThemeData.light().textTheme.subtitle1!.copyWith(
                      color: Utils.secondaryColor,
                    ),
                headline6: ThemeData.light().textTheme.headline6!.copyWith(
                      color: Utils.secondaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                headline5: ThemeData.light().textTheme.headline5!.copyWith(
                      color: Utils.secondaryColor,
                      fontWeight: FontWeight.w400,
                    ),
              ),
        ),
        //   home: const Loading(),

        routes: {
          Loading.route: (_) => const Loading(),
          Home.route: (_) => const Home(),
          homenologin.route: (_) => homenologin(),
          HomePage.route: (_) => const HomePage(),
          BookingPage.route: (_) => const BookingPage(),
          FinishPage.route: (_) => const FinishPage(),
        },
      ),
    );
  }
}
