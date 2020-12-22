import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sorteomovil/src/utils/connection_status.dart';
import 'package:sorteomovil/src/utils/database.dart';
import 'package:sorteomovil/src/utils/license_sm.dart';

abstract class SplashEvent {}

abstract class SplashState {}

class SetSplash extends SplashEvent {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {}

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc(SplashState initialState) : super(initialState);
  @override
  Stream<SplashState> mapEventToState(
    SplashEvent event,
  ) async* {
    if (event is SetSplash) {
      yield SplashLoading();
      await DB.db.initDB();
      bool success = await ConnectionStatus.internal().checkConnection();
      if (success) {
        success = await License.internal().validateKeyIdMovil();
        if (!success) {
          await License.internal().cleanAppUnauthorized();
        } else {
          await License.internal().actualizar();
          await License.internal().vencimiento();
          await License.internal().parametrosLicencias();
        }
      }
      yield SplashLoaded();
    }
  }
}
