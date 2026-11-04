package id.my.iqbalfhz.denlydays

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.provider.MediaStore
import java.io.File
import java.io.IOException
import java.util.zip.CRC32
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

/**
 * ZIP ekspor data (v1.x): `data.json` dan semua fotonya, ditulis langsung ke
 * `Download/Denly Days/{nama}` satu berkas demi satu berkas, supaya tidak butuh ruang dua kali.
 *
 * Selama belum selesai, berkasnya tersembunyi (MediaStore `IS_PENDING` mulai Android 10, atau
 * `.part` sebelumnya), dan dihapus kalau dibatalkan. Jadi tidak pernah ada ZIP yang tidak lengkap.
 * Semua pemanggilan datang dari satu thread latar di `MainActivity`, berurutan.
 */
object ExportZip {
    private const val ROOT = "Denly Days"

    /** Isi ZIP yang boleh ditulis: data, foto profil, dan foto kenangan bernama ULID. */
    private val ENTRY = Regex("^(data\\.json|foto-profil\\.jpg|foto-kenangan/[0-9a-hjkmnp-tv-z]{26}\\.jpg)$")

    private class Session(
        val name: String,
        val zip: ZipOutputStream,
        /** Mulai Android 10: berkas di MediaStore yang masih tersembunyi. */
        val uri: Uri?,
        /** Sebelum Android 10: berkas sementara di folder unduhan milik app. */
        val part: File?,
    )

    private val sessions = HashMap<Int, Session>()
    private var nextId = 1

    /** Buka ZIP baru bernama [name]; mengembalikan nomor sesinya. */
    fun start(context: Context, name: String): Int {
        if (!ExportFiles.isSafeName(name) || !name.endsWith(".zip")) throw IOException("Nama berkas tidak valid")

        val session = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = context.contentResolver
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                put(MediaStore.MediaColumns.MIME_TYPE, "application/zip")
                put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/$ROOT")
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IOException("Folder unduhan menolak berkas")
            val stream = try {
                resolver.openOutputStream(uri) ?: throw IOException("Berkas tidak bisa ditulis")
            } catch (error: Exception) {
                resolver.delete(uri, null, null)
                throw error
            }
            Session(name, ZipOutputStream(stream.buffered()), uri, null)
        } else {
            val part = File(downloadsDir(context), "$name.part")
            Session(name, ZipOutputStream(part.outputStream().buffered()), null, part)
        }

        val id = nextId++
        sessions[id] = session
        return id
    }

    /** Tambahkan [entry]. Foto sudah JPEG, jadi disimpan tanpa kompresi tambahan; data dikompres. */
    fun add(id: Int, entry: String, bytes: ByteArray, compress: Boolean) {
        if (!ENTRY.matches(entry)) throw IOException("Nama isi ZIP tidak valid")
        val session = sessions[id] ?: throw IOException("ZIP sudah ditutup")

        val zipEntry = ZipEntry(entry)
        if (compress) {
            zipEntry.method = ZipEntry.DEFLATED
        } else {
            zipEntry.method = ZipEntry.STORED
            zipEntry.size = bytes.size.toLong()
            zipEntry.compressedSize = bytes.size.toLong()
            zipEntry.crc = CRC32().apply { update(bytes) }.value
        }
        session.zip.putNextEntry(zipEntry)
        session.zip.write(bytes)
        session.zip.closeEntry()
    }

    /**
     * Tutup ZIP dan munculkan di folder unduhan. Mengembalikan nama berkasnya (bisa diberi nomor
     * oleh Android kalau namanya sudah ada), letak foldernya, dan alamatnya untuk dibagikan.
     */
    fun finish(context: Context, id: Int): Map<String, String> {
        val session = sessions.remove(id) ?: throw IOException("ZIP sudah ditutup")
        try {
            session.zip.close()
        } catch (error: Exception) {
            discard(context, session)
            throw error
        }

        val uri = session.uri
        if (uri != null) {
            val resolver = context.contentResolver
            resolver.update(uri, ContentValues().apply { put(MediaStore.MediaColumns.IS_PENDING, 0) }, null, null)
            val name = resolver.query(uri, arrayOf(MediaStore.MediaColumns.DISPLAY_NAME), null, null, null)?.use {
                if (it.moveToFirst()) it.getString(0) else null
            } ?: session.name
            return mapOf(
                "name" to name,
                "location" to "${Environment.DIRECTORY_DOWNLOADS}/$ROOT",
                "uri" to uri.toString(),
            )
        }

        val part = session.part!!
        val target = freeTarget(part.parentFile!!, session.name)
        if (!part.renameTo(target)) {
            part.delete()
            throw IOException("Berkas tidak bisa disimpan")
        }
        return mapOf("name" to target.name, "location" to target.parent.orEmpty(), "path" to target.absolutePath)
    }

    /** Batalkan ZIP yang belum selesai dan hapus berkasnya. Aman dipanggil untuk sesi yang sudah ditutup. */
    fun cancel(context: Context, id: Int) {
        val session = sessions.remove(id) ?: return
        try {
            session.zip.close()
        } catch (_: Exception) {
            // Berkasnya tetap dihapus.
        }
        discard(context, session)
    }

    /** Ruang kosong di penyimpanan bersama, tempat folder unduhan berada, dalam byte. */
    fun freeSpace(context: Context): Long {
        val dir = context.getExternalFilesDir(null) ?: context.filesDir
        return StatFs(dir.path).availableBytes
    }

    private fun discard(context: Context, session: Session) {
        session.uri?.let { context.contentResolver.delete(it, null, null) }
        session.part?.delete()
    }

    private fun downloadsDir(context: Context): File {
        val base = context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
            ?: throw IOException("Penyimpanan tidak tersedia")
        return File(base, ROOT).apply { mkdirs() }
    }

    /** Nama yang belum dipakai di [dir]: `nama.zip`, lalu `nama (1).zip`, dan seterusnya. */
    private fun freeTarget(dir: File, name: String): File {
        var target = File(dir, name)
        var number = 1
        val stem = name.removeSuffix(".zip")
        while (target.exists()) {
            target = File(dir, "$stem ($number).zip")
            number++
        }
        return target
    }
}
