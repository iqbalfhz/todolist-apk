package id.my.iqbalfhz.denlydays

import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
import java.io.File
import java.io.IOException
import java.io.InputStream
import java.util.zip.ZipInputStream

/**
 * Berkas ekspor yang dipilih untuk diimpor (v1.x): file JSON, atau ZIP berisi `data.json` dan
 * `foto-kenangan/{id}.jpg`. Isi JSON dibaca ke memori; foto disalin ke `impor/{token}` di folder
 * app sampai diunggah. Isi ZIP lainnya, termasuk `foto-profil.jpg`, diabaikan.
 */
object ImportFiles {
    /** Data JSON paling besar 64 MB, supaya berkas yang salah pilih tidak menghabiskan memori. */
    private const val MAX_JSON = 64L * 1024 * 1024

    /** Satu foto paling besar 32 MB; foto kenangan versi penuh biasanya di bawah 2 MB. */
    private const val MAX_PHOTO = 32L * 1024 * 1024

    /** Nama folder dari app: ULID huruf kecil, supaya tidak bisa menunjuk folder lain. */
    private val TOKEN = Regex("^[0-9a-hjkmnp-tv-z]{26}$")

    /** Hanya foto kenangan bernama ULID yang diambil; nama lain tidak pernah dijadikan berkas. */
    private val PHOTO = Regex("^foto-kenangan/([0-9a-hjkmnp-tv-z]{26})\\.jpg$")

    /**
     * Baca berkas [uri]. Mengembalikan nama berkasnya, jenisnya (`json` atau `zip`), isi JSON
     * (`null` kalau ZIP tanpa `data.json`), dan foto per ID beserta letaknya di HP.
     */
    fun read(context: Context, uri: Uri, token: String): Map<String, Any?> {
        if (!TOKEN.matches(token)) throw IOException("Folder impor tidak valid")
        val resolver = context.contentResolver
        val name = displayName(context, uri)

        val zip = resolver.openInputStream(uri)?.use { stream ->
            val head = ByteArray(4)
            stream.read(head) == 4 && head[0] == 'P'.code.toByte() && head[1] == 'K'.code.toByte() &&
                head[2] == 3.toByte() && head[3] == 4.toByte()
        } ?: throw IOException("Berkas tidak bisa dibuka")

        if (!zip) {
            val json = resolver.openInputStream(uri)?.use { readText(it) } ?: throw IOException("Berkas tidak bisa dibuka")
            return mapOf("name" to name, "kind" to "json", "json" to json, "photos" to emptyMap<String, String>())
        }

        val folder = folder(context, token).apply {
            deleteRecursively()
            mkdirs()
        }
        var json: String? = null
        val photos = HashMap<String, String>()
        try {
            resolver.openInputStream(uri)?.use { raw ->
                ZipInputStream(raw.buffered()).use { entries ->
                    while (true) {
                        val entry = entries.nextEntry ?: break
                        if (entry.isDirectory) continue
                        if (entry.name == "data.json") {
                            json = readText(entries)
                            continue
                        }
                        val id = PHOTO.matchEntire(entry.name)?.groupValues?.get(1) ?: continue
                        val file = File(folder, "$id.jpg")
                        if (copyLimited(entries, file)) photos[id] = file.absolutePath else file.delete()
                    }
                }
            } ?: throw IOException("Berkas tidak bisa dibuka")
        } catch (error: Exception) {
            folder.deleteRecursively()
            throw error
        }

        return mapOf("name" to name, "kind" to "zip", "json" to json, "photos" to photos)
    }

    /** Hapus foto impor [token] yang tidak dibutuhkan lagi. */
    fun discard(context: Context, token: String) {
        if (TOKEN.matches(token)) folder(context, token).deleteRecursively()
    }

    private fun folder(context: Context, token: String) = File(context.filesDir, "impor/$token")

    private fun displayName(context: Context, uri: Uri): String =
        context.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use {
            if (it.moveToFirst()) it.getString(0) else null
        } ?: uri.lastPathSegment.orEmpty()

    private fun readText(stream: InputStream): String {
        val buffer = java.io.ByteArrayOutputStream()
        val chunk = ByteArray(64 * 1024)
        var total = 0L
        while (true) {
            val read = stream.read(chunk)
            if (read < 0) break
            total += read
            if (total > MAX_JSON) throw IOException("Berkas terlalu besar")
            buffer.write(chunk, 0, read)
        }
        return buffer.toString(Charsets.UTF_8.name())
    }

    /** Salin isi ZIP yang sedang dibaca ke [file]; `false` kalau melewati [MAX_PHOTO]. */
    private fun copyLimited(stream: InputStream, file: File): Boolean {
        val chunk = ByteArray(64 * 1024)
        var total = 0L
        file.outputStream().buffered().use { out ->
            while (true) {
                val read = stream.read(chunk)
                if (read < 0) break
                total += read
                if (total > MAX_PHOTO) return false
                out.write(chunk, 0, read)
            }
        }
        return true
    }
}
