// ignore_for_file: use_build_context_synchronously

import 'package:vidaagroconsumidor/components/buttons/primary_button.dart';
import 'package:vidaagroconsumidor/screens/signin/sign_in_screen.dart';
import 'package:vidaagroconsumidor/shared/components/bottomNavigation/bottom_navigation.dart';
import 'package:vidaagroconsumidor/shared/components/dialogs/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:vidaagroconsumidor/components/appBar/custom_app_bar.dart';
import 'package:vidaagroconsumidor/components/forms/custom_ink.dart';
import 'package:vidaagroconsumidor/screens/screens_index.dart';
import 'package:vidaagroconsumidor/shared/constants/style_constants.dart';
import 'package:vidaagroconsumidor/shared/core/user_storage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserStorage userStorage = UserStorage();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: BottomNavigation(
        paginaSelecionada: 3,
      ),
      body: Material(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: kDetailColor,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: isSmallScreen ? 50 : 60,
                      color: Colors.white,
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    FutureBuilder<String>(
                      future: userStorage.getUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Carregando...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                          );
                        } else if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Text(
                            'Convidado',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        } else {
                          String nameToShow =
                              snapshot.data!.split(' ').take(3).join(' ');
                          return Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    nameToShow,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 18 : 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: isSmallScreen ? 18 : 20,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, Screens.perfilEditar);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  CustomInkWell(
                    icon: Icons.shopping_bag,
                    text: 'Pedidos',
                    onTap: () =>
                        Navigator.pushNamed(context, Screens.purchases),
                  ),
                  CustomInkWell(
                    icon: Icons.location_on,
                    text: 'Endereços',
                    onTap: () =>
                        Navigator.pushNamed(context, Screens.selectAdress),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.02,
                right: size.width * 0.02,
                bottom: isSmallScreen ? 12 : 20,
              ),
              child: PrimaryButton(
                text: 'Sair da conta',
                onPressed: () {
                  confirmDialog(
                    context,
                    'Confirmação',
                    'Você tem certeza que deseja sair da conta?',
                    'Cancelar',
                    'Confirmar',
                    onConfirm: () async {
                      await userStorage.clearUserCredentials();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  );
                },
                color: kDetailColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}