# **Sorteo Móvil**

Aplicación de sorteos de ticker para lotería locales.

## **Estructura del proyecto**

```batch
📦lib
 ┣ 📂src
 ┃ ┣ 📂blocs
 ┃ ┣ 📂models
 ┃ ┣ 📂utils
 ┃ ┣ 📂views
 ┃ ┣ 📂widget
 ┃ ┃ ┣ 📂appbar
 ┃ ┃ ┣ 📂inputs
 ┃ ┃ ┣ 📂menu
 ┃ ┃ ┣ 📂sidebar
 ┃ ┃ ┣ 📂various
 ┃ ┗ 📂widgets
 ┗ 📜main.dart
```

### **Requisitos del app**

* [Android Studio](https://developer.android.com/studio)
* [Flutter](https://flutter.dev/docs/get-started/install)
* [Vscode](https://code.visualstudio.com/)
* [Cuenta Githud](https://github.com/)
* [Git](https://git-scm.com/)

### **Conceptos genericos**

**Link de play console**
[Play console]([https://link](https://play.google.com/apps/publish/?account=7940713336700536901#AppListPlace))

**Comando para correr la aplicacion:**

```bash
#correr en plataformas arm
flutter build apk --target-platform android-arm64
#Este para subir ala play store
flutter build appbundle --target-platform android-arm,android-arm64,android-x64
#Para enviar apk de prueba
flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi
#Version release
flutter build apk --release
#Correr aplicacion
flutter run
#creacion de icono en la  aplicacion.
flutter pub run flutter_launcher_icons:main
#generar nuevo nombre ala app
flutter pub run flutter_launcher_name:main
```

**Agregando imagenes:**

Se agregan en al carpeta **assets** del proyecto.

**Agregando parametros a los storage:**

```dart
/*Storage clase que contiene los metodos para obtener del storage
--tipos compatibles
int
String --> marshell a jsonstring para un objeto
bool
double
*/
 await Storage.setStorage("prueba", "hola");
```

**Obteniendo parametros en el storage:**

```dart
/*Constantes iniciales que estaran en el storage state*/
final Map<String, dynamic> paramsInit = {
  "prueba":nd
};
```

**Agregando parametro al proyecto:**

```dart
/*paramValues: Contiene las constantes del proyecto*/
final Map<String, dynamic> paramValues = {
  "prueba": 555,
};
```

**Para mandar a llamar un mensaje string global:**

```dart
//se agreaga un key en la variable  values
final Map<String,String> valuesMsj = {
  "appname":"VentasLocas"
};
```

**Para agregar un router:**

```dart
/*
se agreaga un key en la variable  values agregando  el widget deseado
*/
final routers = <String,WidgetBuilder>{
  "splash":(BuildContext ctx)=> SplashView(),
};
```

**Configurando temas principales:**

```dart
final themeGlobal=ThemeData(
      primaryColor: HexColor.fromHex("#673AB7"),
      accentColor: HexColor.fromHex("#536DFE"),
);
```
