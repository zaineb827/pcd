package com.example.ey

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity


class FullScreenActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_full_screen)

        // Fermer automatiquement après 5 secondes
        Handler(Looper.getMainLooper()).postDelayed({
            finish()
        }, 5000)
    }
}
