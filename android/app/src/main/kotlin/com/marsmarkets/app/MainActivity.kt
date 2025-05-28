package com.marsmarkets.scanner

import android.os.Bundle;
import android.window.SplashScreenView
import androidx.core.view.WindowCompat;
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterFragmentActivity() {
    override fun getRenderMode(): RenderMode {
        return RenderMode.surface
    }
}