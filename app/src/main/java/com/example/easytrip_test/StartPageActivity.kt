package com.example.easytrip_test

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import com.example.easytrip_test.login.LoginActivity
import com.example.easytrip_test.login.SignUpActivity

class StartPageActivity : AppCompatActivity() {

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_startpage)

    // 액션바 숨기기
    supportActionBar?.hide()

    // 핸들러를 사용하여 지연 실행
    Handler(Looper.getMainLooper()).postDelayed({
      val intent = Intent(this, LoginActivity::class.java)
      startActivity(intent)
      finish()
    }, 3000) // 3000 밀리초 = 3초
  }

}
