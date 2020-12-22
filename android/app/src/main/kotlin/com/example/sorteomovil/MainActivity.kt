package com.sorteo.crazysales

import androidx.annotation.NonNull
import com.example.hoinprinterlib.HoinPrinter
import com.example.hoinprinterlib.module.PrinterCallback
import com.example.hoinprinterlib.module.PrinterEvent
import com.example.sorteomovil.utils.getListDevices
import com.example.sorteomovil.utils.isEnabled
import com.example.sorteomovil.utils.turnOff
import com.example.sorteomovil.utils.turnOn
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sorteo.crazysales/Blue"

    private lateinit var mHoinPrinter: HoinPrinter

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isEnabled" -> {
                    result.success(isEnabled())
                }
                "turnOn" -> {
                    turnOn()
                    result.success(null)
                }
                "turnOff" -> {
                    turnOff()
                    result.success(null)
                }
                "getListDevices" -> {
                    result.success(getListDevices())
                }
                "connectImp" -> {
                    val mac = call.argument<String>("mac")
                    mHoinPrinter = HoinPrinter.getInstance(context, 1, object : PrinterCallback {
                        override fun onState(p0: Int) {
                            print("onState")
                        }

                        override fun onError(p0: Int) {
                            print("onError")
                        }

                        override fun onEvent(p0: PrinterEvent?) {
                            print("onEvente")
                        }
                    })
                    val resultado = mac?.let { connectImp(it) }

                    when (resultado) {
                        "Success" -> {
                            result.success("Success")
                        }
                        "Error" -> {
                            result.error("001", "Error al conectar", null)
                        }
                        else -> {
                            result.error("001", "Error al conectar", null)

                        }
                    }

                }
                "imprimir" -> {
                    val recibo = call.argument<String>("recibo")
                    if (recibo != null) {
                        imprimir(recibo)
                    }
                }
                "desconnectImp" -> {
                    desconnectImp()
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    fun connectImp(mac: String): String = try {
        mHoinPrinter.connect(mac)
        "Success"
    } catch (e: Exception) {
        "Error"
    }

    fun imprimir(recibo: String) {
        mHoinPrinter.setCenter(true)
        mHoinPrinter.switchType(true)
        mHoinPrinter.printText(recibo, false, false, false, false)
    }

    fun desconnectImp() {
        mHoinPrinter.destroy()
    }
}
