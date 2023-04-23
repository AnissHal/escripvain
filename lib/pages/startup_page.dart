import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:escripvain/api/requests.dart';
import 'package:escripvain/constants.dart';
import 'package:escripvain/pages/home_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  bool notice = false;
  String usernameErrorText = '';

  @override
  void initState() {
    checkNotice();

    super.initState();
  }

  void acceptNotice() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notice = !notice;
      prefs.setBool('notice', true);
    });
  }

  void checkNotice() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('notice') != null) {
      setState(() {
        notice = true;
      });
    }
  }

  void editCreateUser() async {
    createUser(uuid as String, usernameTextController.text).then((value) => {
          if (value != null)
            {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: ((context) => HomePage())))
            }
          else
            {
              setState(() {
                usernameErrorText = 'Erreur lors de la création';
              })
            }
        });
  }

  TextEditingController usernameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            maintainBottomViewPadding: true,
            child: Stack(
              children: [
                Visibility(
                  visible: !notice,
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(26),
                            child: Text(
                              "Merci d'avoir installer cette application, avant de l'utiliser sachez que cette application est toujours en teste et une démonstration pour le mémoire",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent),
                              onPressed: () => acceptNotice(),
                              child: const Icon(
                                Icons.arrow_right_alt_outlined,
                                size: 64,
                              ))
                        ],
                      )),
                ),
                Visibility(
                    visible: notice,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            height: 200,
                            width: 250,
                            child: Container(
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                          AssetImage('assets/images/logo.png'),
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center)),
                            )),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                "Créer un compte en donnant un nom d'utilisateur de votre choix",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: TextFormField(
                                    cursorColor: Colors.grey,
                                    maxLength: 20,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Entrer un texte au minimum une lettre';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      icon: const Icon(
                                          Icons.account_box_outlined),
                                      errorText: usernameErrorText,
                                      labelText: "Nom d'utilisateur",
                                      labelStyle: const TextStyle(
                                        color: Color(0xFF6200EE),
                                      ),
                                      helperText: "Entrer n'importe quel nom",
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFF6200EE)),
                                      ),
                                    ),
                                  )),
                              ElevatedButton(
                                  onPressed: () {
                                    editCreateUser();
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    child: Text('Commencer',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                  ))
                            ]),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text("Faculté des langues étragères"),
                            // SizedBox(
                            //   height: 4,
                            // ),
                            // SizedBox(
                            //     height: 60,
                            //     width: 60,
                            //     child: Container(
                            //       decoration: const BoxDecoration(
                            //           image: DecorationImage(
                            //               image: AssetImage(
                            //                   'assets/images/uhbc_bw.png'),
                            //               fit: BoxFit.contain,
                            //               alignment: Alignment.center)),
                            //     )),
                            // SizedBox(
                            //   height: 4,
                            // ),
                            const Text("Aniss HALFAOUI"),
                            const Text("Bilal ZIANE-MAMMAR"),
                          ],
                        )
                      ],
                    ))
              ],
            )));
  }
}
