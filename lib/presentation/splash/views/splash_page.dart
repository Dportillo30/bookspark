import 'package:bookspark/config/constants/s_img.dart';
import 'package:bookspark/config/constants/s_sizes.dart';
import 'package:flutter/material.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

    static Page<void> page() => const MaterialPage<void>(child: SplashPage());

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  bool animate = false;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width * 0.25,
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
            const SizedBox(width: tDefaultSize),
            Image(
              height: MediaQuery.of(context).size.height * 0.5,
              image: const AssetImage(tSplashImage_light),
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width * 0.25,
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
            const SizedBox(width: tDefaultSize),
          ],
        ),
      ),
      
    );
  }
  
}
