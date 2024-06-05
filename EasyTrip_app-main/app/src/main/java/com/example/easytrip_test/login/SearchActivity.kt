package com.example.easytrip_test.login

import android.app.Activity
import android.database.Cursor
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import com.example.easytrip_test.R
import com.example.easytrip_test.db.Database

class SearchActivity : Activity(), View.OnClickListener {

  private lateinit var searchName: EditText
  private lateinit var searchBirth: EditText
  private lateinit var searchId: EditText
  private lateinit var searchNamePw: EditText
  private lateinit var searchBirthPw: EditText

  private lateinit var tsearchName: String
  private lateinit var tsearchBirth: String
  private lateinit var tsearchId: String
  private lateinit var tsearchNamePw: String
  private lateinit var tsearchBirthPw: String

  private lateinit var cursor: Cursor

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_search)

    searchName = findViewById(R.id.SearchName) // 아이디 찾기의 이름 입력 란
    searchBirth = findViewById(R.id.SearchBirth) // 아아디 찾기의 생년월일 입력 란
    searchId = findViewById(R.id.SearchId) // 비밀번호 찾기의 아이디 입력 란
    searchNamePw = findViewById(R.id.SearchNamePw) // 비밀번호 찾기의 이름 입력 란
    searchBirthPw = findViewById(R.id.SearchBirthPw) // 비밀번호 찾기의 생년월일 입력 란

    val searchIdbtn: Button = findViewById(R.id.SearchIdbtn)
    val searchPwbtn: Button = findViewById(R.id.SearchPwbtn)
    searchIdbtn.setOnClickListener(this)
    searchPwbtn.setOnClickListener(this)
  }

  override fun onClick(v: View) {
    when (v.id) {
      R.id.SearchIdbtn -> { // 아이디 찾기 버튼
        tsearchName = searchName.text.toString()
        tsearchBirth = searchBirth.text.toString()

        if (tsearchName.isEmpty() || tsearchBirth.isEmpty()) {
          Toast.makeText(this, "빈칸 없이 모두 입력하세요!", Toast.LENGTH_SHORT).show()
          Log.d("minsu", "아이디 찾기 공백 발생")
          return
        }

        cursor = Database.getInstance().findId(tsearchName, tsearchBirth)
        if (cursor.count != 1) {
          Toast.makeText(this, "입력한 정보가 존재하지 않습니다!", Toast.LENGTH_SHORT).show()
          return
        } else {
          Toast.makeText(this, "아이디는 ${cursor.getString(0)} 입니다!", Toast.LENGTH_SHORT).show()
        }
        cursor.close() // 꼭 닫아주어야 함
      }

      R.id.SearchPwbtn -> { // 비밀번호 찾기 버튼
        tsearchId = searchId.text.toString()
        tsearchNamePw = searchNamePw.text.toString()
        tsearchBirthPw = searchBirthPw.text.toString()

        if (tsearchId.isEmpty() || tsearchNamePw.isEmpty() || tsearchBirthPw.isEmpty()) {
          Toast.makeText(this, "빈칸 없이 모두 입력하세요!", Toast.LENGTH_SHORT).show()
          Log.d("minsu", "비밀번호 찾기 공백 발생")
          return
        }

        cursor = Database.getInstance().findPw(tsearchId, tsearchNamePw, tsearchBirthPw)
        if (cursor.count != 1) {
          Toast.makeText(this, "입력한 정보가 존재하지 않습니다!", Toast.LENGTH_SHORT).show()
          return
        } else {
          Toast.makeText(this, "비밀번호는 ${cursor.getString(0)} 입니다!", Toast.LENGTH_SHORT).show()
        }

        cursor.close() // 꼭 닫아주어야 함
      }
    }
  }
}
