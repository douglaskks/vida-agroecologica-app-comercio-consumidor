import 'package:vidaagroconsumidor/assets/index.dart';
import 'package:vidaagroconsumidor/components/utils/vertical_spacer_box.dart';
import 'package:vidaagroconsumidor/shared/constants/app_enums.dart';
import 'package:vidaagroconsumidor/shared/constants/app_number_constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BottomLogos extends StatelessWidget {
  double spaceHeight;
  BottomLogos(this.spaceHeight, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Desenvolvido por:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const VerticalSpacerBox(size: SpacerSize.small),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        Assets.ufapeLogo,
                        width: 65,
                      ),
                      const SizedBox(width: 20),
                      Image.asset(
                        Assets.lmtsLogo,
                        width: 65,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Parcerias:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const VerticalSpacerBox(size: SpacerSize.large),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        Assets.logoVidaAgro,
                        width: 65,
                      ),
                      const SizedBox(width: 20),
                      Image.asset(
                        Assets.logoPosGraduacao,
                        width: 65,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
