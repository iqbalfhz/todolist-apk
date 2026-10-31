package id.my.iqbalfhz.denlydays

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import java.io.File
import java.io.IOException

/**
 * Hasil ekspor data (v1.0): berkas JSON dan fotonya, disimpan ke `Download/Denly Days/{folder}`.
 *
 * Mulai Android 10 lewat MediaStore, jadi tanpa izin penyimpanan dan langsung terlihat di
 * aplikasi Files. Sebelumnya ke folder unduhan milik app, yang juga tanpa izin.
 */
object ExportFiles {
    private const val ROOT = "Denly Days"

    /** Nama folder dan berkas yang boleh dipakai: tanpa garis miring, jadi tidak bisa keluar dari folder ekspor. */
    private val SAFE_NAME = Regex("^[A-Za-z0-9][A-Za-z0-9._-]*$")

    fun isSafeName(name: String): Boolean = SAFE_NAME.matches(name) && !name.contains("..")

    /** Simpan [bytes] sebagai [name] di folder ekspor [folder]; mengembalikan letak foldernya. */
    fun save(context: Context, folder: String, name: String, mimeType: String, bytes: ByteArray): String {
        if (!isSafeName(folder) || !isSafeName(name)) throw IOException("Nama berkas tidak valid")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val relative = "${Environment.DIRECTORY_DOWNLOADS}/$ROOT/$folder"
            val resolver = context.contentResolver
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, relative)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IOException("Folder unduhan menolak berkas")
            try {
                val stream = resolver.openOutputStream(uri) ?: throw IOException("Berkas tidak bisa ditulis")
                stream.use { it.write(bytes) }
                values.clear()
                values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
            } catch (error: Exception) {
                resolver.delete(uri, null, null)
                throw error
            }
            return relative
        }

        val base = context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
            ?: throw IOException("Penyimpanan tidak tersedia")
        val dir = File(base, "$ROOT/$folder").apply { mkdirs() }
        File(dir, name).writeBytes(bytes)
        return dir.absolutePath
    }
}
