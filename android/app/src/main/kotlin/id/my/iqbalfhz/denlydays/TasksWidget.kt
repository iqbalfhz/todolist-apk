package id.my.iqbalfhz.denlydays

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * Widget "Tugas hari ini" di layar utama HP (v1.x): tugas yang tenggatnya hari ini atau sudah
 * terlewat, dan target tabungan utama. Hanya untuk dilihat; ketuk membuka app.
 *
 * Isinya ringkasan dari app ([save]) yang disimpan di SharedPreferences app ini. Ringkasan
 * memuat tugas sampai 7 hari ke depan, jadi "hari ini" dihitung ulang di sini setiap widget
 * diperbarui (paling jarang 30 menit sekali) walaupun app belum dibuka lagi.
 */
class TasksWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) update(context, manager, id)
    }

    override fun onAppWidgetOptionsChanged(context: Context, manager: AppWidgetManager, id: Int, options: Bundle) {
        update(context, manager, id)
    }

    companion object {
        private const val PREFS = "denlydays_widget"
        private const val KEY = "snapshot"

        private val ROWS = intArrayOf(R.id.task_row_0, R.id.task_row_1, R.id.task_row_2, R.id.task_row_3, R.id.task_row_4)
        private val TITLES = intArrayOf(R.id.task_title_0, R.id.task_title_1, R.id.task_title_2, R.id.task_title_3, R.id.task_title_4)
        private val METAS = intArrayOf(R.id.task_meta_0, R.id.task_meta_1, R.id.task_meta_2, R.id.task_meta_3, R.id.task_meta_4)

        /** Simpan ringkasan baru dari app (atau hapus dengan `null`), lalu perbarui semua widget. */
        fun save(context: Context, json: String?) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().apply {
                if (json == null) remove(KEY) else putString(KEY, json)
            }.apply()

            val manager = AppWidgetManager.getInstance(context)
            for (id in manager.getAppWidgetIds(ComponentName(context, TasksWidget::class.java))) {
                update(context, manager, id)
            }
        }

        /** Minta launcher menyematkan widget ini. `false` kalau launcher tidak mendukungnya. */
        fun requestPin(context: Context): Boolean {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
            val manager = AppWidgetManager.getInstance(context)
            if (!manager.isRequestPinAppWidgetSupported) return false
            return manager.requestPinAppWidget(ComponentName(context, TasksWidget::class.java), null, null)
        }

        private fun update(context: Context, manager: AppWidgetManager, id: Int) {
            // Banyaknya baris mengikuti tinggi widget.
            val height = manager.getAppWidgetOptions(id).getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
            val rows = if (height <= 0) 3 else ((height - 72) / 24).coerceIn(1, ROWS.size)
            manager.updateAppWidget(id, render(context, rows))
        }

        private fun render(context: Context, maxRows: Int): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.widget_tasks)

            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
            }
            if (launch != null) {
                val pending = PendingIntent.getActivity(
                    context,
                    0,
                    launch,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                views.setOnClickPendingIntent(R.id.widget_root, pending)
            }

            for (row in ROWS) views.setViewVisibility(row, View.GONE)
            views.setViewVisibility(R.id.widget_more, View.GONE)
            views.setViewVisibility(R.id.widget_goal, View.GONE)
            views.setTextViewText(R.id.widget_count, "")

            val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
            val snapshot = raw?.let { runCatching { JSONObject(it) }.getOrNull() }
            if (snapshot == null || !snapshot.optBoolean("signed_in")) {
                views.setTextViewText(R.id.widget_empty, context.getString(R.string.widget_signed_out))
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                return views
            }

            val zone = TimeZone.getTimeZone(snapshot.optString("timezone", "Asia/Jakarta"))
            val now = Date()
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).apply { timeZone = zone }.format(now)
            val clock = SimpleDateFormat("HH:mm", Locale.US).apply { timeZone = zone }.format(now)

            // Urutannya sudah dari app: tenggat paling lama dulu, lalu jamnya.
            val tasks = snapshot.optJSONArray("tasks")
            val due = mutableListOf<JSONObject>()
            if (tasks != null) {
                for (i in 0 until tasks.length()) {
                    val task = tasks.optJSONObject(i) ?: continue
                    if (task.optString("due") <= today) due.add(task)
                }
            }

            if (due.isEmpty()) {
                views.setTextViewText(R.id.widget_empty, context.getString(R.string.widget_empty))
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_empty, View.GONE)
                views.setTextViewText(R.id.widget_count, context.getString(R.string.widget_count, due.size))

                val shown = minOf(due.size, maxRows)
                for (i in 0 until shown) {
                    val task = due[i]
                    val date = task.optString("due")
                    val time = if (task.isNull("time")) null else task.optString("time")
                    val overdue = date < today || (date == today && time != null && time < clock)

                    views.setViewVisibility(ROWS[i], View.VISIBLE)
                    views.setTextViewText(TITLES[i], task.optString("title"))
                    views.setTextViewText(
                        METAS[i],
                        when {
                            overdue -> context.getString(R.string.widget_overdue)
                            time != null -> time.replace(':', '.')
                            else -> ""
                        },
                    )
                    views.setTextColor(
                        METAS[i],
                        context.getColor(if (overdue) R.color.widget_warn else R.color.widget_muted),
                    )
                }
                if (due.size > shown) {
                    views.setTextViewText(R.id.widget_more, context.getString(R.string.widget_more, due.size - shown))
                    views.setViewVisibility(R.id.widget_more, View.VISIBLE)
                }
            }

            val goal = snapshot.optJSONObject("goal")
            if (goal != null) {
                views.setTextViewText(
                    R.id.widget_goal,
                    context.getString(R.string.widget_goal, goal.optString("label"), goal.optInt("percent")),
                )
                views.setViewVisibility(R.id.widget_goal, View.VISIBLE)
            }
            return views
        }
    }
}
