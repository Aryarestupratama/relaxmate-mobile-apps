package id.my.relaxboss.relaxmate.overlay

import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import id.my.relaxboss.relaxmate.R

/**
 * Mini-panel maskot (CMP-M18): nama, sapaan lokal, aksi Ngobrol dan Istirahatkan, dan tombol
 * tutup. Tanpa data pengguna dan tanpa jaringan. Aksi "Bicara" menyusul bersama mode suara
 * (Fase 2). Dibangun dari kode karena overlay berjalan tanpa mesin Flutter.
 */
class OverlayPanel(
    context: Context,
    private val actions: Actions,
) : LinearLayout(context) {

    interface Actions {
        fun onChat()
        fun onRestHour()
        fun onRestTomorrow()
        fun onTurnOff()
        fun onDismissPanel()
    }

    init {
        orientation = VERTICAL
        val pad = dp(16)
        setPadding(pad, pad, pad, pad)
        background = GradientDrawable().apply {
            setColor(context.getColor(R.color.overlay_card))
            setStroke(dp(1), context.getColor(R.color.overlay_border))
            cornerRadius = dp(16).toFloat()
        }
        elevation = dp(8).toFloat()

        addView(header(context))
        addView(
            TextView(context).apply {
                text = context.getString(R.string.overlay_panel_greeting)
                textSize = 16f
                setTextColor(context.getColor(R.color.overlay_text))
                setPadding(0, dp(8), 0, dp(12))
            },
        )
        addView(primaryButton(context, R.string.overlay_action_chat) { actions.onChat() })
        addView(secondaryButton(context, R.string.overlay_action_rest_hour) { actions.onRestHour() })
        addView(
            secondaryButton(context, R.string.overlay_action_rest_tomorrow) { actions.onRestTomorrow() },
        )
        addView(
            TextView(context).apply {
                text = context.getString(R.string.overlay_action_turn_off)
                textSize = 14f
                gravity = Gravity.CENTER
                minHeight = dp(48)
                setTextColor(context.getColor(R.color.overlay_text_secondary))
                setOnClickListener { actions.onTurnOff() }
            },
        )
    }

    private fun header(context: Context): View {
        val row = LinearLayout(context).apply { gravity = Gravity.CENTER_VERTICAL }
        row.addView(
            TextView(context).apply {
                text = context.getString(R.string.overlay_panel_name)
                textSize = 18f
                setTextColor(context.getColor(R.color.overlay_text))
                setTypeface(typeface, android.graphics.Typeface.BOLD)
            },
            LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f),
        )
        row.addView(
            TextView(context).apply {
                text = "✕"
                textSize = 18f
                gravity = Gravity.CENTER
                minWidth = dp(48)
                minHeight = dp(48)
                setTextColor(context.getColor(R.color.overlay_text_secondary))
                contentDescription = context.getString(R.string.overlay_action_close_panel)
                setOnClickListener { actions.onDismissPanel() }
            },
        )
        return row
    }

    private fun primaryButton(context: Context, label: Int, onClick: () -> Unit): Button =
        Button(context).apply {
            text = context.getString(label)
            isAllCaps = false
            minHeight = dp(48)
            setTextColor(context.getColor(R.color.overlay_on_primary))
            background = GradientDrawable().apply {
                setColor(context.getColor(R.color.overlay_primary))
                cornerRadius = dp(12).toFloat()
            }
            setOnClickListener { onClick() }
        }

    private fun secondaryButton(context: Context, label: Int, onClick: () -> Unit): Button =
        Button(context).apply {
            text = context.getString(label)
            isAllCaps = false
            minHeight = dp(48)
            setTextColor(context.getColor(R.color.overlay_text))
            background = GradientDrawable().apply {
                setColor(context.getColor(R.color.overlay_surface_alt))
                cornerRadius = dp(12).toFloat()
            }
            setOnClickListener { onClick() }
        }

    /** Sentuhan di luar panel (diminta lewat `FLAG_WATCH_OUTSIDE_TOUCH`) menutup panel. */
    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (event.action == MotionEvent.ACTION_OUTSIDE) {
            actions.onDismissPanel()
            return true
        }
        return super.onTouchEvent(event)
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    companion object {
        /** Lebar kartu 280dp (CMP-M18). */
        const val WIDTH_DP = 280
    }
}
