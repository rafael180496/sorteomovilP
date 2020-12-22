import 'dart:async';
import 'package:sorteomovil/src/models/Ticket.dart';

class TicketBloc {
  final _ticketsController = StreamController<List<Tickets>>.broadcast();

  get tickets => _ticketsController.stream;

  TicketBloc() {
    getTickets();
  }

  getTickets(
      {DateTime fechaIni,
      DateTime fechaFin,
      int sorteo: -1,
      int cliente: -1}) async {
    _ticketsController.sink.add(await TicketModel.getAll(
        cliente: cliente,
        sorteo:sorteo,
        fechaIni: fechaIni,
        fechaFin: fechaFin,
        inCliente: true,
        inSorteo: true,
        inDet: true));
  }

  addTicket(Tickets ticket) async {
    await TicketModel.insert(ticket);
    getTickets();
  }

  deleteTicket(int id) async {
    await TicketModel.delete(id: id);
    getTickets();
  }

  dispose() {
    _ticketsController.close();
  }
}
