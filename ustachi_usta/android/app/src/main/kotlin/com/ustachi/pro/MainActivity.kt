package com.ustachi.pro

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {

    companion object {
        /**
         * BILDIRISHNOMA KANALI — id UCH JOYDA bir xil bo'lishi SHART:
         *   1. shu yerda (kanal aynan shu id bilan yaratiladi);
         *   2. `AndroidManifest.xml` →
         *      `com.google.firebase.messaging.default_notification_channel_id`;
         *   3. serverda → `FCM_ANDROID_CHANNEL` (`apps/accounts/services/push.py`
         *      `AndroidNotification(channel_id=...)` bo'lib yuboradi).
         *
         * ⚠️ Mos kelmasa xabar YO'QOLMAYDI, lekin Android uni ZAXIRA kanalga
         * ("Miscellaneous") tashlaydi: ovoz ham, ekrandagi banner ham
         * yo'qoladi va foydalanuvchi buni "push kelmayapti" deb biladi.
         * 2026-08-24 gacha aynan shunday edi — ilova
         * `high_importance_channel` yaratardi, server esa `usta_top` so'rardi.
         */
        private const val CHANNEL_ID = "usta_top"
        private const val CHANNEL_NAME = "Muhim bildirishnomalar"
        private const val CHANNEL_DESCRIPTION = "Buyurtma va chat xabarlari"

        /** Endi ishlatilmaydigan eski kanal — sozlamalarda osilib qolmasin. */
        private const val LEGACY_CHANNEL_ID = "high_importance_channel"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        // Android 8.0 (Oreo) dan past — kanal tushunchasi yo'q.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(Context.NOTIFICATION_SERVICE)
                as NotificationManager

        // Eski id bilan yaratilgan kanal telefonda qolib ketgan bo'lishi
        // mumkin (yangilangan ilovalarda). U endi hech qachon ishlatilmaydi —
        // sozlamalarda "o'lik" qator bo'lib turmasin.
        manager.deleteNotificationChannel(LEGACY_CHANNEL_ID)

        // OHANG: android/app/src/main/res/raw/notification_sound.mp3
        val soundUri: Uri = Uri.parse(
            "android.resource://${packageName}/raw/notification_sound"
        )
        val audioAttr = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH,   // heads-up banner
        ).apply {
            description = CHANNEL_DESCRIPTION
            setSound(soundUri, audioAttr)
            enableVibration(true)
            enableLights(true)
        }

        // ⚠️ Kanal BIR MARTA yaratiladi: keyin ohang/muhimlik o'zgartirilsa
        // Android eskisini saqlab qoladi. O'zgartirish kerak bo'lsa — YANGI
        // id (yuqoridagi uch joyda birga) yoki ilovani qayta o'rnatish.
        manager.createNotificationChannel(channel)
    }
}
