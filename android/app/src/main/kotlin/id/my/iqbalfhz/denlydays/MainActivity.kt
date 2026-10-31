package id.my.iqbalfhz.denlydays

import android.graphics.BitmapFactory
import android.media.ExifInterface
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Nama HP untuk `device_name` saat masuk, dan versi Android untuk izin notifikasi.
                "info" -> result.success(
                    mapOf(
                        "manufacturer" to Build.MANUFACTURER,
                        "brand" to Build.BRAND,
                        "model" to Build.MODEL,
                        "sdkInt" to Build.VERSION.SDK_INT,
                    ),
                )

                "photoInfo" -> result.success(photoInfo(call.argument<String>("path").orEmpty()))

                // Widget "Tugas hari ini" (v1.x): ringkasan baru dari app, atau null saat keluar.
                "updateWidget" -> {
                    TasksWidget.save(applicationContext, call.argument<String>("json"))
                    result.success(null)
                }

                "pinWidget" -> result.success(TasksWidget.requestPin(applicationContext))

                // Ekspor data (v1.0): tulis di luar thread utama, karena foto bisa beberapa MB.
                "saveDownload" -> {
                    val folder = call.argument<String>("folder").orEmpty()
                    val name = call.argument<String>("name").orEmpty()
                    val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes == null) {
                        result.error("invalid", "Isi berkas kosong", null)
                    } else {
                        Thread {
                            try {
                                val location = ExportFiles.save(applicationContext, folder, name, mimeType, bytes)
                                runOnUiThread { result.success(location) }
                            } catch (error: Exception) {
                                runOnUiThread { result.error("save_failed", error.message, null) }
                            }
                        }.start()
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    /**
     * Ukuran asli dan waktu pengambilan foto kenangan, dibaca sebelum fotonya dikompres,
     * karena hasil kompresnya tidak lagi membawa EXIF.
     */
    private fun photoInfo(path: String): Map<String, Any?>? {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null

        val exif = try {
            ExifInterface(path)
        } catch (_: Exception) {
            null
        }

        return mapOf(
            "width" to bounds.outWidth,
            "height" to bounds.outHeight,
            "takenAt" to exif?.getAttribute("DateTimeOriginal"),
            "offset" to exif?.getAttribute("OffsetTimeOriginal"),
        )
    }

    private companion object {
        const val CHANNEL = "todolist/device"
    }
}
