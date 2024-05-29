package com.example.easytrip_test.login

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.CheckBox
import android.widget.EditText
import android.widget.Spinner
import android.widget.Toast
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
  private lateinit var tage: String

  private var pwCheck: Boolean = false
  private lateinit var genderSpinner: Spinner
  private lateinit var ageSpinner: Spinner
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

    val genderData = listOf("남자", "여자")
    genderSpinner = findViewById(R.id.gender_spinner)
    adapterSpinner = ArrayAdapter(this, android.R.layout.simple_spinner_item, genderData)
    adapterSpinner.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
    genderSpinner.adapter = NothingSelectedSpinnerAdapter(adapterSpinner, R.layout.spinner_row_nothing_selected_gender, this)

    genderSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
      override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
        if (genderSpinner.getItemAtPosition(position) != null) {
          tgender = genderSpinner.getItemAtPosition(position).toString()
        }
      }

      override fun onNothingSelected(parent: AdapterView<*>) {}
    }

    // 나이 데이터를 설정
    val ages = (18..100).map { it.toString() } // 18세부터 100세까지 선택 가능
    val ageAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, ages)
    ageAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
    ageSpinner = findViewById(R.id.age_spinner)
    ageSpinner.adapter = ageAdapter

    ageSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
      override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
        if (ageSpinner.getItemAtPosition(position) != null) {
          tage = ageSpinner.getItemAtPosition(position).toString()
        }
      }

      override fun onNothingSelected(parent: AdapterView<*>) {}
    }
  }

  override fun onClick(v: View) {
    when (v.id) {
      R.id.Joinbtn -> handleSignUp()
      R.id.watch_btn1 -> showPopupActivity1()
      R.id.watch_btn2 -> showPopupActivity2()
      R.id.inform_check -> handleInformCheck()
    }
  }

  private fun handleSignUp() {
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

    if (tage.isEmpty()) {
      Toast.makeText(this, "나이를 선택해주세요!", Toast.LENGTH_SHORT).show()
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

  private fun showPopupActivity1() {
    val intent = Intent(this, PopupActivity_1::class.java)
    startActivityForResult(intent, 1)
  }

  private fun showPopupActivity2() {
    val intent = Intent(this, PopupActivity_2::class.java)
    startActivityForResult(intent, 2)
  }

  private fun handleInformCheck() {
    if (result1 == null || result2 == null) {
      informCheck.isChecked = false
      Toast.makeText(this, "이용약관 및 개인정보정책 내용을 \n확인해주세요!", Toast.LENGTH_SHORT).show()
    }
  }

  private fun performSignUp() {
    // 실제 회원가입 로직을 수행하는 함수
    // 여기에 데이터를 서버에 전송하거나 로컬 DB에 저장하는 등의 작업을 수행할 수 있습니다.
    resetProgressBar() // 프로그레스바 초기화
    Toast.makeText(this, "회원가입 완료!", Toast.LENGTH_SHORT).show()
    finish() // 회원가입 액티비티 종료
  }

  private fun resetProgressBar() {
    val sharedPref = getSharedPreferences("progress_prefs", Context.MODE_PRIVATE)
    with(sharedPref.edit()) {
      putInt("progress", 0)
      apply()
    }
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    if (resultCode == Activity.RESULT_OK) {
      when (requestCode) {
        1 -> result1 = data?.getStringExtra("result")
        2 -> result2 = data?.getStringExtra("result")
      }
      if (result1 == closePopup1 && result2 == closePopup2) {
        informCheck.isChecked = true
        informCheck.isEnabled = false
      }
    }
  }
}