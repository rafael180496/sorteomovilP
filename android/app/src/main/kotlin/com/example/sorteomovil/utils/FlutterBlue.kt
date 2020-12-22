package com.example.sorteomovil.utils

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothClass
import android.bluetooth.BluetoothDevice
import android.content.Context
import com.example.hoinprinterlib.HoinPrinter
import com.example.hoinprinterlib.module.PrinterCallback
import com.example.hoinprinterlib.module.PrinterEvent
import java.lang.Exception

fun turnOn() = BluetoothAdapter.getDefaultAdapter().enable()

fun turnOff() = BluetoothAdapter.getDefaultAdapter().disable()

fun isEnabled(): Boolean = BluetoothAdapter.getDefaultAdapter().isEnabled

fun getListDevices(): MutableList<Map<String, Map<String, String>>> {
    val mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
    val pairedDevices: Set<BluetoothDevice> = mBluetoothAdapter.bondedDevices
    var data: MutableList<Map<String, Map<String, String>>> = mutableListOf()
    pairedDevices.forEach {
        val type = it.bluetoothClass.deviceClass
        var tipo: String
        when (type) {
            BluetoothClass.Device.COMPUTER_DESKTOP -> {
                tipo = "DESKTOP"
            }
            BluetoothClass.Device.COMPUTER_LAPTOP -> {
                tipo = "LAPTOP"
            }
            BluetoothClass.Device.PHONE_CELLULAR -> {
                tipo = "PHONE"
            }
            BluetoothClass.Device.PHONE_SMART -> {
                tipo = "PHONE"
            }
            else -> {
                tipo = "PRINTER"
            }
        }
        val map = mapOf<String, Map<String, String>>(
                it.address to mapOf<String, String>(
                        "name" to it.name,
                        "type" to tipo
                )
        )
        data.add(map)
    }
    return data;
}

class Printer {

    companion object {

        private lateinit var mHoinPrinter: HoinPrinter

        @Volatile
        private var INSTANCE: Printer? = null

        fun getInstance(context: Context): Printer =
                INSTANCE ?: synchronized(this) {
                    INSTANCE ?: buildImp(context).also {
                        INSTANCE = it
                    }
                }

        private fun buildImp(context: Context): Printer {
            mHoinPrinter = 
            return Printer()
        }
    }

    private lateinit var mHoinPrinter: HoinPrinter

    
}

