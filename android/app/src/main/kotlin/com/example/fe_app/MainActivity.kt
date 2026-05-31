package com.example.fe_app

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // 앱 종료 후 재실행 시 캐시된 엔진이 깨진 상태로 남지 않도록 합니다.
    override fun shouldDestroyEngineWithHost(): Boolean = true
}
