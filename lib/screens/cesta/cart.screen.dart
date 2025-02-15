import 'package:vidaagroconsumidor/components/utils/horizontal_spacer_box.dart';
import 'package:vidaagroconsumidor/components/utils/vertical_spacer_box.dart';
import 'package:vidaagroconsumidor/components/appBar/custom_app_bar.dart';
import 'package:vidaagroconsumidor/screens/cesta/card_cart.dart';
import 'package:vidaagroconsumidor/screens/pedidos/finalizar/finalize_purchase_screen.dart';
import 'package:vidaagroconsumidor/shared/components/bottomNavigation/bottom_navigation.dart';
import 'package:vidaagroconsumidor/shared/components/dialogs/notice_dialog.dart';
import 'package:vidaagroconsumidor/shared/constants/app_enums.dart';
import 'package:vidaagroconsumidor/shared/constants/style_constants.dart';
import 'package:vidaagroconsumidor/shared/core/models/produto_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../components/buttons/primary_button.dart';
import '../../shared/constants/app_number_constants.dart';
import 'cart_controller.dart';
import 'cart_provider.dart';
import 'package:vidaagroconsumidor/shared/core/models/banca_model.dart';
import 'package:vidaagroconsumidor/shared/core/controllers/banca_controller.dart';

class CartScreen extends StatefulWidget {
  final ProdutoModel? selectedProduct;

  const CartScreen({super.key, this.selectedProduct});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    final cartListProvider = Provider.of<CartProvider>(context);
    Size size = MediaQuery.of(context).size;

    return GetBuilder<CartController>(
      init: CartController(),
      builder: (controller) => Scaffold(
        appBar: const CustomAppBar(),
        bottomNavigationBar: BottomNavigation(paginaSelecionada: selectedIndex),
        body: Container(
          color: kOnSurfaceColor,
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const HorizontalSpacerBox(size: SpacerSize.small),
                  Text(
                    NumberFormat.simpleCurrency(
                            locale: 'pt-BR', decimalDigits: 2)
                        .format(cartListProvider.total),
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const VerticalSpacerBox(size: SpacerSize.medium),
              PrimaryButton(
                text: 'Fechar Pedido (${cartListProvider.itens} itens)',
                onPressed: () {
                  if (cartListProvider.itens != 0) {
                    BancaController bancaController = Provider.of<BancaController>(context, listen: false);
                    
                    // Pega o storeId (ID da banca) do primeiro item no carrinho
                    int? bancaId = cartListProvider.listCart.first.storeId;
                    
                    // Verificação adicional para garantir que temos um ID válido
                    if (bancaId == null) {
                      alertDialog(
                        context,
                        'Aviso',
                        'Erro ao identificar a banca do produto.',
                      );
                      return;
                    }

                    // Encontra a banca correspondente
                    BancaModel? bancaTemp;
                    try {
                      bancaTemp = bancaController.bancas.firstWhere(
                        (banca) => banca?.id == bancaId,
                      );
                    } catch (e) {
                      bancaTemp = null;
                    }

                    // Verifica se encontrou a banca e se ela não é nula
                    if (bancaTemp != null) {
                      print('Banca selecionada: ${bancaTemp.nome}, ID: ${bancaTemp.id}'); // Debug
                      
                      // Aqui garantimos que a banca não é nula
                      BancaModel bancaSelecionada = bancaTemp;
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinalizePurchaseScreen(
                            cartListProvider.listCart,
                            banca: bancaSelecionada, // Agora passamos uma BancaModel não nullable
                          ),
                        ),
                      );
                    } else {
                      alertDialog(
                        context,
                        'Aviso',
                        'Não foi possível encontrar a banca selecionada.',
                      );
                    }
                  } else {
                    alertDialog(
                      context,
                      'Aviso',
                      'Sua cesta está vazia. Para fechar um pedido, adicione produtos a ela primeiro.',
                    );
                  }
                },
                color: kDetailColor,
              ),
              const VerticalSpacerBox(size: SpacerSize.large),
              Expanded(
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return CardCart(
                          cartListProvider.retriveCardItem(index), controller);
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        height: size.height * 0.03,
                        color: Colors.transparent,
                      );
                    },
                    itemCount: cartListProvider.listCart.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
