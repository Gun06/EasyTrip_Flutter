package com.example.easytrip_test.ui.mypage

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.ImageButton
import android.widget.Spinner
import androidx.appcompat.app.AppCompatActivity
import com.example.easytrip_test.MainActivity
import com.example.easytrip_test.R
import com.example.easytrip_test.databinding.ActivityMypageEditBinding

class MypageEditActivity : AppCompatActivity() {

  private lateinit var binding: ActivityMypageEditBinding
  private lateinit var genderSpinner: Spinner
  private lateinit var ageSpinner: Spinner
  private lateinit var tgender: String
  private lateinit var tage: String

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    binding = ActivityMypageEditBinding.inflate(layoutInflater)
    setContentView(binding.root)

    // 타이틀바 숨기기
    supportActionBar?.hide()

    // 초기화 및 데이터 설정
    initSpinners()

    // 완료 버튼 클릭 리스너 설정
    binding.editProfileSuccess.setOnClickListener {
      saveProfileData()
      navigateToMypage()
    }

    binding.editSuccessProfileButton.setOnClickListener {
      saveProfileData()
      navigateToMypage()
    }

    // 뒤로가기 버튼 클릭 리스너 설정
    binding.root.findViewById<ImageButton>(R.id.back_button).setOnClickListener {
      navigateToMypageWithoutSaving()
    }
  }

  private fun initSpinners() {
    // 성별 스피너 설정
    val genderData = listOf("남자", "여자")
    genderSpinner = binding.genderSpinner
    val genderAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, genderData)
    genderAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
    genderSpinner.adapter = genderAdapter

    genderSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
      override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
        if (genderSpinner.getItemAtPosition(position) != null) {
          tgender = genderSpinner.getItemAtPosition(position).toString()
        }
      }

      override fun onNothingSelected(parent: AdapterView<*>) {}
    }

    // 나이 스피너 설정
    val ages = (8..100).map { it.toString() } // 18세부터 100세까지 선택 가능
    ageSpinner = binding.ageSpinner
    val ageAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, ages)
    ageAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
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

  private fun saveProfileData() {
    // 프로필 데이터를 저장하는 로직 추가
    val name = binding.InputName.text.toString()
    val studentId = binding.Inputstudentid.text.toString()
    val password = binding.Inputpw.text.toString()
    val phoneNumber = binding.InputPhoneNumber.text.toString()

    // 저장 로직 예시 (SharedPreferences 사용)
    val sharedPreferences = getSharedPreferences("profile_data", MODE_PRIVATE)
    with(sharedPreferences.edit()) {
      putString("name", name)
      putString("studentId", studentId)
      putString("password", password)
      putString("phoneNumber", phoneNumber)
      putString("gender", tgender)
      putString("age", tage)
      apply()
    }
  }

  private fun navigateToMypage() {
    // MypageFragment로 이동
    val intent = Intent(this, MainActivity::class.java)
    intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
    startActivity(intent)
    finish()
  }

  private fun navigateToMypageWithoutSaving() {
    // MypageFragment로 이동 (저장하지 않고)
    val intent = Intent(this, MainActivity::class.java)
    intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
    startActivity(intent)
    finish()
  }
}
