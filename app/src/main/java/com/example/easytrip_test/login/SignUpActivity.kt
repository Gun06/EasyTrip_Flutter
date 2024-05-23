/*
package com.example.easytrip_test.login

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.*
import com.example.easytrip_test.R
import com.example.easytrip_test.db.Database
import com.example.easytrip_test.popUp.PopupActivity_1
import com.example.easytrip_test.popUp.PopupActivity_2
import com.example.easytrip_test.spinnerAdapter.NothingSelectedSpinnerAdapter
import java.util.regex.Pattern

class SignUpActivity : Activity(), View.OnClickListener {

  private lateinit var database: SQLiteDatabase
  private lateinit var id: EditText
  private lateinit var pw: EditText
  private lateinit var pwConfirm: EditText
  private lateinit var birth: EditText
  private lateinit var name: EditText
  private lateinit var phoneNum: EditText
  private lateinit var informCheck: CheckBox
  private lateinit var intent: Intent
  private lateinit var cursor: Cursor

  private lateinit var tid: String
  private lateinit var tpw: String
  private lateinit var tpwConfirm: String
  private lateinit var tname: String
  private lateinit var tbirth: String
  private lateinit var tgender: String
  private lateinit var tphoneNum: String

  private var pwCheck: Boolean = false
  private lateinit var spinner: Spinner
  private lateinit var adapterSpinner: ArrayAdapter<String>

  private val closePopup1 = "Close Popup_1"
  private val closePopup2 = "Close Popup_2"
  private var result1: String? = null
  private var result2: String? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_signup)
    database = Database.getInstance().open(this)!!
    Log.d("minsu", "데이터베이스 사용 가능")

    id = findViewById(R.id.InputId)
    pw = findViewById(R.id.InputPw)
    pwConfirm = findViewById(R.id.InputConfirmPw)
    name = findViewById(R.id.InputName)
    birth = findViewById(R.id.InputBirth)
    phoneNum = findViewById(R.id.PhoneNumber)
    informCheck = findViewById(R.id.inform_check) // 이용약관 및 정보 동의
    informCheck.setOnClickListener(this)

    val joinBtn: Button = findViewById(R.id.Joinbtn) // 회원가입
    val watchBtn1: Button = findViewById(R.id.watch_btn1) // 이용약관 보기
    val watchBtn2: Button = findViewById(R.id.watch_btn2) // 개인정보제공 보기
    joinBtn.setOnClickListener(this)
    watchBtn1.setOnClickListener(this)
    watchBtn2.setOnClickListener(this)

    val data = listOf("남자", "여자")
    spinner = findViewById(R.id.spinner)
    adapterSpinner = ArrayAdapter(this, R.layout.support_simple_spinner_dropdown_item, data)
    adapterSpinner.setDropDownViewResource(R.layout.support_simple_spinner_dropdown_item)

    spinner.adapter = NothingSelectedSpinnerAdapter(adapterSpinner, R.layout.spinner_row_nothing_selected, this)

    // 이벤트 처리
    spinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
      override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
        // Toast.makeText(SignUpActivity.this, "선택된 아이템 : " + spinner.getItemAtPosition(position), Toast.LENGTH_SHORT).show();
        if (spinner.getItemAtPosition(position) != null) { // 처음 기본 텍스트(성별) 상태이면 if 문 실행X
          tgender = spinner.getItemAtPosition(position).toString()
        }
      }

      override fun onNothingSelected(parent: AdapterView<*>) {}
    }
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    if (requestCode == 1 && resultCode == RESULT_OK) {
      // 데이터 받기
      result1 = data?.getStringExtra("result_1")
      result1.toString()
    }

    if (requestCode == 2 && resultCode == RESULT_OK) {
      // 데이터 받기
      result2 = data?.getStringExtra("result_2")
      result2.toString()
    }

    if (result1 != null && result2 != null) {
      if (result1 == closePopup1 && result2 == closePopup2) { // 정보 제공, 이용 약관 모두 확인 시
        informCheck.isChecked = true // 체크 박스 체크
        informCheck.isEnabled = false // 체크 박스 사용 불가 상태
      }
    }
  }

  override fun onClick(v: View) {
    when (v.id) {
      R.id.Joinbtn -> { // 회원가입 버튼
        tid = id.text.toString()
        tpw = pw.text.toString()
        tpwConfirm = pwConfirm.text.toString()
        tname = name.text.toString()
        tbirth = birth.text.toString()
        tphoneNum = phoneNum.text.toString()
        pwCheck = Pattern.matches("^(?=.*\\d)(?=.*[~`!@#$%^&*()-])(?=.*[a-zA-Z]).{6,16}$", tpw)

        if (tid.trim().isEmpty() || tpw.trim().isEmpty() || tpwConfirm.trim().isEmpty() || tbirth.trim().isEmpty() || tname.trim().isEmpty() || tphoneNum.trim().isEmpty()) {
          Toast.makeText(this, "빈칸 없이 모두 입력하세요!", Toast.LENGTH_SHORT).show()
          Log.d("minsu", "공백 발생")
          return
        }

        if (tgender.isEmpty()) {
          Toast.makeText(this, "성별을 선택해주세요!", Toast.LENGTH_SHORT).show()
          Log.d("minsu", "성별 미 선택")
          return
        }

        cursor = Database.getInstance().searchId(tid)
        if (cursor.count != 0) {
          Toast.makeText(this, "존재하는 아이디입니다!", Toast.LENGTH_SHORT).show()
          Log.d("minsu", "아이디 중복")
        } else if (tpw != tpwConfirm) {
          Toast.makeText(this, "비밀번호가 일치하지 않습니다!", Toast.LENGTH_SHORT).show()
        } else if (!pwCheck) {
          Toast.makeText(this, "비밀번호는 6~16자 영문 대 소문자, 숫자, 특수문자의 조합을 사용하세요!", Toast.LENGTH_SHORT).show()
        } else if (spaceCheck(tpw)) {
          Toast.makeText(this, "비밀번호에 공백을 사용할 수 없습니다!", Toast.LENGTH_SHORT).show()
        } else if (!informCheck.isChecked) {
          Toast.makeText(this, "이용약관 및 사용자 정보제공 \n동의는 필수입니다!", Toast.LENGTH_SHORT).show()
        } else {
          Database.getInstance().insert(database, tid, tpw, tname, tbirth, tgender, tphoneNum)
          Toast.makeText(this, "회원가입 완료!", Toast.LENGTH_SHORT).show()
          finish()
          Log.d("minsu", "회원가입 완료")
        }

        cursor.close() // 꼭 닫아주어야 함
      }

      R.id.watch_btn1 -> { // 이용약관 보기 버튼
        intent = Intent(this, PopupActivity_1::class.java)
        startActivityForResult(intent, 1) // requestCode 1
      }

      R.id.watch_btn2 -> { // 정보제공 보기 버튼
        intent = Intent(this, PopupActivity_2::class.java)
        startActivityForResult(intent, 2) // requestCode 2
      }

      R.id.inform_check -> {
        if (result1 == null || result2 == null) { // 내용 미 확인 후 동의 체크 시
          informCheck.isChecked = false
          Toast.makeText(this, "이용약관 및 개인정보정책 내용을 \n확인해주세요!", Toast.LENGTH_SHORT).show()
        }
      }
    }
  }

  private fun spaceCheck(spaceCheck: String): Boolean { // 문자열 안에 스페이스 체크
    for (i in spaceCheck.indices) {
      if (spaceCheck[i] == ' ') return true
    }
    return false
  }
}
*/
package com.example.easytrip_test.login

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.*
import com.example.easytrip_test.R
import com.example.easytrip_test.popUp.PopupActivity_1
import com.example.easytrip_test.popUp.PopupActivity_2
import com.example.easytrip_test.spinnerAdapter.NothingSelectedSpinnerAdapter
import java.util.regex.Pattern

class SignUpActivity : Activity(), View.OnClickListener {

  private lateinit var id: EditText
  private lateinit var pw: EditText
  private lateinit var pwConfirm: EditText
  private lateinit var birth: EditText
  private lateinit var name: EditText
  private lateinit var informCheck: CheckBox

  private lateinit var tid: String
  private lateinit var tpw: String
  private lateinit var tpwConfirm: String
  private lateinit var tname: String
  private lateinit var tbirth: String
  private lateinit var tgender: String

  private var pwCheck: Boolean = false
  private lateinit var spinner: Spinner
  private lateinit var adapterSpinner: ArrayAdapter<String>

  private val closePopup1 = "Close Popup_1"
  private val closePopup2 = "Close Popup_2"
  private var result1: String? = null
  private var result2: String? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_signup)

    id = findViewById(R.id.InputId)
    pw = findViewById(R.id.InputPw)
    pwConfirm = findViewById(R.id.InputConfirmPw)
    name = findViewById(R.id.InputName)
    birth = findViewById(R.id.InputBirth)
    informCheck = findViewById(R.id.inform_check)
    informCheck.setOnClickListener(this)

    val joinBtn: Button = findViewById(R.id.Joinbtn)
    val watchBtn1: Button = findViewById(R.id.watch_btn1)
    val watchBtn2: Button = findViewById(R.id.watch_btn2)
    joinBtn.setOnClickListener(this)
    watchBtn1.setOnClickListener(this)
    watchBtn2.setOnClickListener(this)

    val data = listOf("남자", "여자")
    spinner = findViewById(R.id.spinner)
    adapterSpinner = ArrayAdapter(this, android.R.layout.simple_spinner_item, data)
    adapterSpinner.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)

    spinner.adapter = NothingSelectedSpinnerAdapter(adapterSpinner, R.layout.spinner_row_nothing_selected, this)

    spinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
      override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
        if (spinner.getItemAtPosition(position) != null) {
          tgender = spinner.getItemAtPosition(position).toString()
        }
      }

      override fun onNothingSelected(parent: AdapterView<*>) {}
    }
  }

  override fun onClick(v: View) {
    when (v.id) {
      R.id.Joinbtn -> {
        tid = id.text.toString()
        tpw = pw.text.toString()
        tpwConfirm = pwConfirm.text.toString()
        tname = name.text.toString()
        tbirth = birth.text.toString()
        pwCheck = Pattern.matches("^(?=.*\\d)(?=.*[~`!@#$%^&*()-])(?=.*[a-zA-Z]).{6,16}$", tpw)

        if (tid.trim().isEmpty() || tpw.trim().isEmpty() || tpwConfirm.trim().isEmpty() || tbirth.trim().isEmpty() || tname.trim().isEmpty()) {
          Toast.makeText(this, "빈칸 없이 모두 입력하세요!", Toast.LENGTH_SHORT).show()
          return
        }

        if (tgender.isEmpty()) {
          Toast.makeText(this, "성별을 선택해주세요!", Toast.LENGTH_SHORT).show()
          return
        }

        if (tpw != tpwConfirm) {
          Toast.makeText(this, "비밀번호가 일치하지 않습니다!", Toast.LENGTH_SHORT).show()
          return
        }

        if (!pwCheck) {
          Toast.makeText(this, "비밀번호는 6~16자 영문 대 소문자, 숫자, 특수문자의 조합을 사용하세요!", Toast.LENGTH_SHORT).show()
          return
        }

        if (!informCheck.isChecked) {
          Toast.makeText(this, "이용약관 및 사용자 정보제공 \n동의는 필수입니다!", Toast.LENGTH_SHORT).show()
          return
        }

        // 회원가입 로직을 수행하는 함수 호출
        performSignUp()
      }

      R.id.watch_btn1 -> {
        intent = Intent(this, PopupActivity_1::class.java)
        startActivityForResult(intent, 1)
      }

      R.id.watch_btn2 -> {
        intent = Intent(this, PopupActivity_2::class.java)
        startActivityForResult(intent, 2)
      }

      R.id.inform_check -> {
        if (result1 == null || result2 == null) {
          informCheck.isChecked = false
          Toast.makeText(this, "이용약관 및 개인정보정책 내용을 \n확인해주세요!", Toast.LENGTH_SHORT).show()
        }
      }
    }
  }

  private fun performSignUp() {
    // 실제 회원가입 로직을 수행하는 함수
    // 여기에 데이터를 서버에 전송하거나 로컬 DB에 저장하는 등의 작업을 수행할 수 있습니다.
    Toast.makeText(this, "회원가입 완료!", Toast.LENGTH_SHORT).show()
    finish() // 회원가입 액티비티 종료
  }
}

