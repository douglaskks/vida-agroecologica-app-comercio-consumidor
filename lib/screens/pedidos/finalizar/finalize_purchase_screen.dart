// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:vidaagroconsumidor/components/appBar/custom_app_bar.dart';
import 'package:vidaagroconsumidor/screens/cesta/cart_provider.dart';
import 'package:vidaagroconsumidor/shared/core/controllers/profile_controller.dart';
import 'package:vidaagroconsumidor/shared/core/controllers/purchase_controller.dart';
import 'package:vidaagroconsumidor/shared/core/models/banca_model.dart';
import 'package:vidaagroconsumidor/shared/core/models/cart_model.dart';
import 'package:vidaagroconsumidor/shared/core/models/endereco_model.dart';
import 'package:flutter/material.dart';
import 'package:vidaagroconsumidor/components/utils/horizontal_spacer_box.dart';
import 'package:vidaagroconsumidor/components/utils/vertical_spacer_box.dart';
import 'package:vidaagroconsumidor/screens/screens_index.dart';
import 'package:vidaagroconsumidor/shared/constants/app_enums.dart';
import 'package:vidaagroconsumidor/shared/constants/style_constants.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vidaagroconsumidor/shared/core/models/pedidos_model.dart';
import 'package:vidaagroconsumidor/shared/core/repositories/pagamento_repository.dart';
import '../../../components/buttons/primary_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vidaagroconsumidor/shared/core/models/banca_model.dart';
import '../../../shared/core/controllers/pagamento_controller.dart';

class FinalizePurchaseScreen extends StatefulWidget {
  final List<CartModel> cartModel;
  final Map<String, dynamic>? addressData;
  final BancaModel banca;

  const FinalizePurchaseScreen(this.cartModel, {required this.banca, this.addressData, super.key});

  @override
  State<FinalizePurchaseScreen> createState() => _FinalizePurchaseScreenState();
}

class _FinalizePurchaseScreenState extends State<FinalizePurchaseScreen> {
  String _deliveryMethod = 'retirada';
  int _paymentMethodId = 1;
  AddressModel? userAddress;
  bool isLoading = true;
  late int selectedAddressId;
  String? pixCode;
  XFile? _comprovanteImage;


  @override
  void initState() {
    super.initState();
    _loadUserAddress();
    print('Banca recebida: ${widget.banca.nome}');  // Nome da banca
    print('ID da banca: ${widget.banca.id}');       // ID da banca
    print('PIX da banca: ${widget.banca.pix}');
    pixCode = widget.banca.pix;  // Pegando a chave Pix da banca
  }

  Future<void> _loadUserAddress() async {
    final profileController =
    Provider.of<ProfileController>(context, listen: false);
    await profileController.fetchUserAddresses();
    setState(() {
      if (profileController.addresses.isNotEmpty) {
        userAddress = profileController.addresses.first;
        selectedAddressId = userAddress!.id;
      }
      isLoading = false;
    });
  }

  void _chooseAddress(
      BuildContext context, ProfileController controller) async {
    final AddressModel? selectedAddress = await showDialog<AddressModel>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Escolha um endereço!',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.addresses.length,
              itemBuilder: (BuildContext context, int index) {
                var address = controller.addresses[index];
                return ListTile(
                  leading: Text(
                    '${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: Text('${address.rua}, ${address.numero}'),
                  subtitle:
                  Text('${address.cidadeNome}, ${address.bairroNome} '),
                  onTap: () => Navigator.pop(context, address),
                );
              },
            ),
          ),
        );
      },
    );
    if (selectedAddress != null) {
      setState(() {
        userAddress = selectedAddress;
        selectedAddressId = selectedAddress.id;
        print("ENDEREÇO: $selectedAddressId");
      });
    }
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Pedido realizado!',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
          content:
          const Icon(Icons.shopping_bag, size: 100, color: kDetailColor),
          actions: <Widget>[
            PrimaryButton(
              text: "OK",
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Screens.home,
                      (Route<dynamic> route) => false,
                );
              },
              color: kDetailColor,
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Erro',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            PrimaryButton(
              text: "OK",
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: kDetailColor,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartListProvider = Provider.of<CartProvider>(context);
    Size size = MediaQuery.of(context).size;
    final profileController =
    Provider.of<ProfileController>(context, listen: false);
    PagamentoRepository pagamentoRepository = PagamentoRepository();
    PagamentoController pagamentoController =
    PagamentoController(pagamentoRepository);


    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(),
          body:
          Center(child: CircularProgressIndicator(color: kDetailColor)))
          : GetBuilder<PurchaseController>(
        init: PurchaseController(listCartModel: widget.cartModel),
        builder: (controller) {
          controller.listCartModel = widget.cartModel;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const CustomAppBar(),
            body: Container(
              color: Colors.white,
              width: size.width,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Forma de entrega',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                            overlayColor:
                            WidgetStateProperty.all(kDetailColor),
                            value: 'retirada',
                            groupValue: _deliveryMethod,
                            activeColor: kDetailColor,
                            focusColor: kDetailColor,
                            hoverColor: kDetailColor,
                            onChanged: (value) {
                              setState(() {
                                _deliveryMethod = value.toString();
                                print(
                                    "Tipo de entrega: $_deliveryMethod");
                              });
                            }),
                        const Text(
                          'Retirada',
                          style: TextStyle(
                              fontSize: 20, color: kTextButtonColor),
                        ),
                        const HorizontalSpacerBox(size: SpacerSize.small),
                        const HorizontalSpacerBox(size: SpacerSize.small),
                      ],
                    ),
                    const VerticalSpacerBox(size: SpacerSize.medium),
                    const Row(
                      children: [
                        Text(
                          'Forma de pagamento',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const VerticalSpacerBox(size: SpacerSize.small),
                    DropdownButtonFormField<int>(
                      value: _paymentMethodId,
                      onChanged: (int? value) {
                        setState(() {
                          _paymentMethodId = value ?? 1;
                        });
                      },
                      items: const [
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Text(
                            'Dinheiro',
                            style:
                            TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 2,
                          child: Text(
                            'Pix',
                            style:
                            TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding:
                        const EdgeInsets.fromLTRB(13, 13, 13, 13),
                      ),
                    ),
                    if (_paymentMethodId == 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Chave PIX do Vendedor:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                pixCode != null ? 'Chave Pix: $pixCode' : 'Pix não disponível',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Comprovante de PIX:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _chooseComprovante();
                                    },
                                    child: const Text("Anexar Comprovante de PIX"),
                                  ),
                                  if (_comprovanteImage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Column(
                                        children: [
                                          const Text("Visualização do comprovante:"),
                                          const SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Image.file(
                                              File(_comprovanteImage!.path),
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) {
                                                print("Erro ao carregar imagem: $error");
                                                return const Text("Erro ao carregar a imagem");
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const VerticalSpacerBox(size: SpacerSize.large),
                    if (_deliveryMethod == 'entrega')
                      InkWell(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kOnSurfaceColor,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                color: kTextButtonColor.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 3,
                                offset: const Offset(0, 0),
                              ),
                            ],
                            border: Border(
                              left: BorderSide(
                                color: kTextButtonColor.withOpacity(0.5),
                                width: 1,
                              ),
                              right: BorderSide(
                                color: kTextButtonColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Endereço de entrega',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                      onPressed: () => _chooseAddress(
                                          context, profileController),
                                      icon: const Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: kTextButtonColor,
                                      )),
                                ],
                              ),
                              const VerticalSpacerBox(
                                  size: SpacerSize.tiny),
                              Text(
                                'Bairro: ${userAddress?.bairroNome ?? 'Bairro não disponível'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const VerticalSpacerBox(
                                  size: SpacerSize.tiny),
                              Text(
                                'Cidade: ${userAddress?.cidadeNome ?? 'Cidade não disponível'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const VerticalSpacerBox(
                                  size: SpacerSize.tiny),
                              Text(
                                'Rua: ${userAddress?.rua ?? 'Rua não disponível'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const VerticalSpacerBox(
                                  size: SpacerSize.tiny),
                              Text(
                                'Número: ${userAddress?.numero ?? 'Número não disponível'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const VerticalSpacerBox(
                                  size: SpacerSize.tiny),
                              if (userAddress?.complemento != null)
                                Text(
                                  'Complemento: ${userAddress?.complemento}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                            ],
                          ),
                        ),
                        onTap: () {},
                      ),
                    const VerticalSpacerBox(size: SpacerSize.medium),
                    InkWell(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kOnSurfaceColor,
                          borderRadius:
                          const BorderRadius.all(Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                              color: kTextButtonColor.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 3,
                              offset: const Offset(0, 0),
                            ),
                          ],
                          border: Border(
                            left: BorderSide(
                              color: kTextButtonColor.withOpacity(0.5),
                              width: 1,
                            ),
                            right: BorderSide(
                              color: kTextButtonColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Resumo de valores',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                              ],
                            ),
                            const VerticalSpacerBox(
                                size: SpacerSize.tiny),
                            const VerticalSpacerBox(
                                size: SpacerSize.small),
                            if (_deliveryMethod == 'retirada')
                              Row(
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _deliveryMethod == 'entrega'
                                        ? 'R\$ ${(controller.totalValue + 5).toStringAsFixed(2)}'
                                        : 'R\$ ${controller.totalValue.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: kTextButtonColor),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      onTap: () {},
                    ),
                    const VerticalSpacerBox(size: SpacerSize.large),
                    PrimaryButton(
                      text: 'Confirmar pedido',
                      onPressed: () async {
                        try {
                          // Validações iniciais
                          if (_paymentMethodId == 2 && _comprovanteImage == null) {
                            throw Exception('Por favor, anexe o comprovante do PIX');
                          }

                          // Tenta criar o pedido
                          final pedidoModel = await controller.purchase(
                            selectedAddressId,
                            _deliveryMethod,
                            _paymentMethodId,
                          );

                          // Processamento do pedido
                          if (pedidoModel.id != null) {
                            if (_paymentMethodId == 2) {
                              await pagamentoController.uploadComprovanteFromXFile(
                                pedidoModel.id!,
                                context,
                                _comprovanteImage!
                              );
                            }
                            
                            cartListProvider.clearCart();
                            showSuccessDialog(context);
                          } else {
                            throw Exception('Pedido não foi criado corretamente');
                          }
                        } catch (e) {
                          String errorMessage = e.toString();
                          if (errorMessage.startsWith('Exception: ')) {
                            errorMessage = errorMessage.substring(10);
                          }
                          showErrorDialog(context, errorMessage);
                        }
                      },
                      color: kDetailColor,
                    ),
                    const VerticalSpacerBox(size: SpacerSize.medium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Screens.cart);
                          },
                          child: const Text(
                            'Voltar a cesta',
                            style: TextStyle(
                                color: kDetailColor, fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isPickerActive = false;

Future<void> _chooseComprovante() async {
  if (_isPickerActive) return; // Evita múltiplas chamadas

  try {
    _isPickerActive = true;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _comprovanteImage = image;
      });
    }
  } catch (e) {
    print('Erro ao selecionar imagem: $e');
  } finally {
    _isPickerActive = false;
  }
}
}