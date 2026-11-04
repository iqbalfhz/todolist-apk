package id.my.iqbalfhz.denlydays

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.graphics.BitmapFactory
import android.media.ExifInterface
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    /**
     * ZIP ekspor dan berkas impor (v1.x) ditulis dan dibaca berurutan di satu thread latar,
     * karena isinya bisa ratusan MB.
     */
    private val fileThread = Executors.newSingleThreadExecutor()

    /** Pemilih berkas impor yang sedang terbuka, dan folder foto untuk hasilnya. */
    private var pendingImport: MethodChannel.Result? = null
    private var pendingImportToken: String? = null

    private fun onFileThread(result: MethodChannel.Result, work: () -> Any?) {
        fileThread.execute {
            try {
                val value = work()
                runOnUiThread { result.success(value) }
            } catch (error: Exception) {
                runOnUiThread { result.error("save_failed", error.message, null) }
            }
        }
    }

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

                // Halaman kebijakan (v1.0) di browser. Hanya HTTPS, supaya kanal ini tidak bisa
                // dipakai membuka skema lain.
                "openUrl" -> {
                    val uri = Uri.parse(call.argument<String>("url").orEmpty())
                    if (uri.scheme != "https") {
                        result.success(false)
                    } else {
                        try {
                            startActivity(Intent(Intent.ACTION_VIEW, uri))
                            result.success(true)
                        } catch (_: ActivityNotFoundException) {
                            result.success(false)
                        }
                    }
                }

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

                // ZIP ekspor data (v1.x): dibuka, diisi satu berkas demi satu berkas, lalu ditutup
                // atau dibatalkan. Selama belum selesai, berkasnya tersembunyi.
                "zipStart" -> onFileThread(result) {
                    ExportZip.start(applicationContext, call.argument<String>("name").orEmpty())
                }

                "zipAdd" -> {
                    val id = call.argument<Int>("id") ?: -1
                    val entry = call.argument<String>("entry").orEmpty()
                    val compress = call.argument<Boolean>("compress") ?: false
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes == null) {
                        result.error("invalid", "Isi berkas kosong", null)
                    } else {
                        onFileThread(result) {
                            ExportZip.add(id, entry, bytes, compress)
                            null
                        }
                    }
                }

                "zipFinish" -> onFileThread(result) { ExportZip.finish(applicationContext, call.argument<Int>("id") ?: -1) }

                "zipCancel" -> onFileThread(result) {
                    ExportZip.cancel(applicationContext, call.argument<Int>("id") ?: -1)
                    null
                }

                "freeSpace" -> onFileThread(result) { ExportZip.freeSpace(applicationContext) }

                // Impor data (v1.x): pilih file JSON atau ZIP. Isinya dibaca di thread latar setelah
                // pemilih berkas ditutup (onActivityResult).
                "pickImportFile" -> {
                    if (pendingImport != null) {
                        result.error("busy", "Pemilih berkas sudah terbuka", null)
                    } else {
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "*/*"
                        }
                        pendingImport = result
                        pendingImportToken = call.argument<String>("token").orEmpty()
                        try {
                            startActivityForResult(intent, REQUEST_IMPORT)
                        } catch (_: ActivityNotFoundException) {
                            pendingImport = null
                            result.success(null)
                        }
                    }
                }

                "discardImport" -> onFileThread(result) {
                    ImportFiles.discard(applicationContext, call.argument<String>("token").orEmpty())
                    null
                }

                // Bagikan berkas di folder unduhan yang dibuat app ini (v1.x). Hanya alamat
                // MediaStore, supaya kanal ini tidak bisa dipakai membagikan berkas lain.
                "shareFile" -> {
                    val uri = Uri.parse(call.argument<String>("uri").orEmpty())
                    if (uri.scheme != "content" || uri.authority != MediaStore.AUTHORITY) {
                        result.success(false)
                    } else {
                        val send = Intent(Intent.ACTION_SEND).apply {
                            type = call.argument<String>("mimeType") ?: "application/octet-stream"
                            putExtra(Intent.EXTRA_STREAM, uri)
                            clipData = ClipData.newRawUri(null, uri)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        try {
                            startActivity(Intent.createChooser(send, null))
                            result.success(true)
                        } catch (_: ActivityNotFoundException) {
                            result.success(false)
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Pemilih berkas impor memakai startActivityForResult bawaan Activity")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_IMPORT) return

        val result = pendingImport ?: return
        val token = pendingImportToken.orEmpty()
        pendingImport = null
        pendingImportToken = null

        val uri = data?.data
        if (resultCode != RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        fileThread.execute {
            try {
                val picked = ImportFiles.read(applicationContext, uri, token)
                runOnUiThread { result.success(picked) }
            } catch (error: Exception) {
                runOnUiThread { result.error("read_failed", error.message, null) }
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
        const val REQUEST_IMPORT = 4021
    }
}
