/*
package com.example.easytrip_test.login

import android.app.Activity
import android.content.Intent
import android.content.SharedPreferences
import android.database.Cursor
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.CheckBox
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import com.example.easytrip_test.R
import com.example.easytrip_test.db.Database
import com.example.easytrip_test.MainActivity
import com.example.easytrip_test.login.SignUpActivity

class LoginActivity : Activity(), View.OnClickListener {

  private lateinit var btnLogin: Button
  private lateinit var btnSignup: TextView
  private lateinit var btnSearch: TextView
  private lateinit var loginId: EditText
  private lateinit var loginPw: EditText
  private lateinit var checkBox: CheckBox
  private lateinit var autoLogin: SharedPreferences
  private lateinit var editor: SharedPreferences.Editor

  private lateinit var id: String
  private lateinit var pw: String
  private lateinit var logoutCode: String
  private lateinit var intent: Intent
  private lateinit var cursor: Cursor

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
    checkBox = findViewById(R.id.autoCheck)

    btnLogin.setOnClickListener(this)
    btnSignup.setOnClickListener(this)
    btnSearch.setOnClickListener(this)

    autoLogin = getSharedPreferences("autoLogin", 0)
    editor = autoLogin.edit()

    intent = intent
    logoutCode = intent.getStringExtra("Logout_Code") ?: "f"
    Log.d("minsu", logoutCode)

    if (autoLogin.getBoolean("chk_auto", false)) {
      loginId.setText(autoLogin.getString("ID", ""))
      loginPw.setText(autoLogin.getString("PW", ""))
      sloginId = autoLogin.getString("ID", "").orEmpty()
      Log.d("minsu", sloginId)

      checkBox.isChecked = true

      if (logoutCode == "f") {
        intent = Intent(this, MainActivity::class.java)
        startActivity(intent)
        finish()
      } else {
        loginId.setText("")
        loginPw.setText("")
        checkBox.isChecked = false

        editor.clear()
        editor.commit()
        return
      }
    }
  }

  override fun onClick(v: View) {
    when (v.id) {
      R.id.login -> {
        id = loginId.text.toString()
        pw = loginPw.text.toString()

        if (id.isEmpty() || pw.isEmpty()) {
          Toast.makeText(this, "아이디 또는 비밀번호를 입력하세요!", Toast.LENGTH_SHORT).show()
          return
        }

        cursor = Database.getInstance().searchId(id)
        if (cursor.count != 1) {
          Toast.makeText(this, "존재하지 않는 아이디입니다!", Toast.LENGTH_SHORT).show()
          return
        }

        cursor = Database.getInstance().searchPw(id)
        if (pw != cursor.getString(0)) {
          Toast.makeText(this, "비밀번호가 틀렸습니다!", Toast.LENGTH_SHORT).show()
        } else {
          if (checkBox.isChecked) {
            editor.putString("ID", id)
            editor.putString("PW", pw)
            editor.putBoolean("chk_auto", true)
            editor.commit()
            cursor = Database.getInstance().searchName(id)
            val name = cursor.getString(0)
            Toast.makeText(this, "고재건님 환영합니다!", Toast.LENGTH_SHORT).show()
          } else {
            editor.clear()
            editor.commit()
            cursor = Database.getInstance().searchName(id)
            val name = cursor.getString(0)
            Toast.makeText(this, "고재건님 환영합니다!", Toast.LENGTH_SHORT).show()
          }

          sloginId = id
          intent = Intent(this, MainActivity::class.java)
          startActivity(intent)
          finish()
        }
        cursor.close()
      }
      R.id.signup -> {
        val intent = Intent(this, SignUpActivity::class.java)
        startActivity(intent)
      }
      R.id.search -> {
        intent = Intent(this, SearchActivity::class.java)
        startActivity(intent)
      }
    }
  }
}
*/

package com.example.easytrip_test.login

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import com.example.easytrip_test.MainActivity
import com.example.easytrip_test.R

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
      R.id.login -> {
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

          // 로그인 성공 시 메인 액티비티로 이동
          startActivity(Intent(this, MainActivity::class.java))
          finish() // 로그인 액티비티 종료
        } else {
          Toast.makeText(this, "아이디 또는 비밀번호가 잘못되었습니다!", Toast.LENGTH_SHORT).show()
        }
      }
      R.id.signup -> {
        // 회원가입 액티비티로 이동
        val intent = Intent(this, SignUpActivity::class.java)
        startActivity(intent)
      }
      R.id.search -> {
        // 비밀번호 찾기 액티비티로 이동
        val intent = Intent(this, SearchActivity::class.java)
        startActivity(intent)
      }
    }
  }
}
