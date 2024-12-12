package com.slashplus.signageplus

import io.flutter.embedding.android.FlutterFragmentActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.DataOutputStream
import io.flutter.plugin.common.StandardMethodCodec
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import android.app.Activity
import android.os.Bundle
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import com.tx.printlib.UsbPrinter


class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "native_channel"

    private var mActivity: Activity? = null
    private lateinit var usbPrinter: UsbPrinter
    
    override fun onCreate(savedInstanceState: Bundle?) {
      super.onCreate(savedInstanceState)
      mActivity = this 
  }

  override fun onDestroy() {
    super.onDestroy()
    mActivity = null 
  }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
      super.configureFlutterEngine(flutterEngine)
      val taskQueue = flutterEngine.dartExecutor.binaryMessenger.makeBackgroundTaskQueue()
      usbPrinter = UsbPrinter(applicationContext)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL, StandardMethodCodec.INSTANCE, taskQueue).setMethodCallHandler {
        call, result -> 
        if (call.method == "runAdbCommand") {
            val command = call.argument<String?>("command")
            val res = runAdbCommand(command)
            result.success(res)
        } else if (call.method == "checkRoot"){
             isDeviceRooted(result);
        }
        else if (call.method == "installApk"){
            val filePath = call.argument<String?>("filePath")
            val res = installNormal(filePath!!)
            result.success(res)
        }
        else if (call.method == "write"){
          val byteArray = call.argument<ByteArray>("byteArray")
          if (byteArray == null) result.error("PARAMETER ERROR", "ByteArray cannot be null", null);
          val device = getPrinter()
          if (device != null && usbPrinter.open(device)) {
              var res = 0;
              usbPrinter.init();
              if (byteArray != null) {
                  res = usbPrinter.write(byteArray);
              };
              usbPrinter.close();
              if (res < 0) {
                  result.error("DEVICE_ERROR", "Error writing to printer", null)
              } else {
                  result.success(res)
              }
          } else {
              result.error("DEVICE_ERROR", "Unable to find or open printer", null)
          }
        }
        else {
            result.notImplemented()
        }
      }
    }

    private fun runAdbCommand(command: String?): String {
        val res = mutableListOf<String>()
        try {
            val su = Runtime.getRuntime().exec("su")
            val outputStream = DataOutputStream(su.outputStream)
    
            outputStream.writeBytes("$command\n")
            outputStream.flush()

            outputStream.writeBytes("exit\n")
            outputStream.flush()

            val stdInput = BufferedReader(InputStreamReader(su.inputStream))
            val stdError = BufferedReader(InputStreamReader(su.errorStream))

            var s: String?
            while (stdInput.readLine().also { s = it } != null)
                res.add(s!!)
            while (stdError.readLine().also { s = it } != null)
                res.add(s!!)

            try {
                su.waitFor()
            } catch (e: InterruptedException) {
                e.printStackTrace()
            }
    
            outputStream.close()
            println("Output: $res")
            return res.toString()
        } catch (e: IOException) {
            e.printStackTrace()
            return "Error: ${e.toString()}"
        }
    }

    private fun isDeviceRooted(@NonNull result: Result) {
        val su = "su"
        val locations = arrayOf(
          "/system/bin/", "/system/xbin/", "/sbin/", "/system/sd/xbin/",
          "/system/bin/failsafe/", "/data/local/xbin/", "/data/local/bin/", "/data/local/"
        )
        var resultReplied = false
        for (location in locations) {
          if (File(location + su).exists()) {
            result.success(true)
            resultReplied = true
            break
          }
        }
    
        if (!resultReplied) result.success(false)
      }

      private fun installNormal(filePath: String) : Boolean {
        val file = File(filePath)
        if (!file.exists()) {
          return false
        }
    
        val intent = Intent(Intent.ACTION_VIEW)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
          val contentUri: Uri = FileProvider.getUriForFile(
            applicationContext,
            applicationContext.packageName + ".fileProvider", file
          )
          intent.setDataAndType(contentUri, "application/vnd.android.package-archive")
        } else {
          intent.setDataAndType(Uri.fromFile(file), "application/vnd.android.package-archive")
        }
    
        mActivity?.startActivity(intent)
    
        return true
      }

      private fun getPrinter(): UsbDevice? {
        val usbMgr = getSystemService(USB_SERVICE) as UsbManager
        val devMap: Map<String, UsbDevice> = usbMgr.getDeviceList()
        for (name in devMap.keys) {
            if (UsbPrinter.checkPrinter(devMap[name]!!)) return devMap[name]
        }
        return null
    }
}