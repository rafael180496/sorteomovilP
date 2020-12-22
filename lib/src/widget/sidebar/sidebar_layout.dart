import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sorteomovil/src/blocs/navigation_bloc.dart';
import 'package:sorteomovil/src/utils/enums.dart';
import 'package:sorteomovil/src/views/tickets_Page/ticket_new_page.dart';

import '../widget.dart';

class SideBarLayout extends StatelessWidget {
  final int tipo;
  final Tarifas tarifa;

  const SideBarLayout({Key key, this.tipo, this.tarifa})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<NavigationBloc>(
        create: (context) => NavigationBloc(
            TicketNewView(this.tipo, this.tarifa)),
        child: Stack(
          children: <Widget>[
            BlocBuilder<NavigationBloc, NavigationStates>(
              builder: (context, state) {
                return state as Widget;
              },
            ),
            SideBar()
          ],
        ),
      ),
    );
  }
}
