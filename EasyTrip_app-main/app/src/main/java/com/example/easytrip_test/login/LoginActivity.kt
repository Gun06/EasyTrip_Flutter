package com.example.easytrip_test.login

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import com.example.easytrip_test.MainActivity
import com.example.easytrip_test.R
import com.example.easytrip_test.preference.PreferenceActivity

class LoginActivity : Activity(), View.OnClickListener {

  private lateinit var btnLogin: Button
  private lateinit var btnSignup: TextView
  private lateinit var btnSearch: TextView
  private lateinit var loginId: EditText
  private lateinit var loginPw: EditText

  companion object {
    lateinit var sloginId: String
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_login)

    loginId = findViewById(R.id.LoginId)
    loginPw = findViewById(R.id.LoginPw)
    btnLogin = findViewById(R.id.login)
    btnSignup = findViewById(R.id.signup)
    btnSearch = findViewById(R.id.search)

    btnLogin.setOnClickListener(this)
    btnSignup.setOnClickListener(this)
    btnSearch.setOnClickListener(this)
  }

  override fun onClick(v: View) {
    when (v.id) {
      R.id.login -> handleLogin()
      R.id.signup -> navigateToPreferenceActivity()
      R.id.search -> navigateToSearchActivity()
    }
  }

  private fun handleLogin() {
    val id = loginId.text.toString()
    val pw = loginPw.text.toString()

    // 하드코딩된 사용자 이름과 비밀번호
    val validId = "1111"
    val validPw = "admin"

    if (id.isEmpty() || pw.isEmpty()) {
      Toast.makeText(this, "아이디 또는 비밀번호를 입력하세요!", Toast.LENGTH_SHORT).show()
      return
    }

    // 로그인 성공 여부를 확인
    if (id == validId && pw == validPw) {
      Toast.makeText(this, "로그인 성공!", Toast.LENGTH_SHORT).show()
      startActivity(Intent(this, MainActivity::class.java))
      finish() // 로그인 액티비티 종료
    } else {
      Toast.makeText(this, "아이디 또는 비밀번호가 잘못되었습니다!", Toast.LENGTH_SHORT).show()
    }
  }

  private fun navigateToPreferenceActivity() {
    val sharedPref = getSharedPreferences("progress_prefs", Context.MODE_PRIVATE)
    with(sharedPref.edit()) {
      putInt("progress", 0) // 진행도 초기화
      apply()
    }
    val intent = Intent(this, PreferenceActivity::class.java)
    intent.putExtra("step", 1)
    startActivity(intent)
  }

  private fun navigateToSearchActivity() {
    val intent = Intent(this, SearchActivity::class.java)
    startActivity(intent)
  }
}
