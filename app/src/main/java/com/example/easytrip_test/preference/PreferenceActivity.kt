package com.example.easytrip_test.preference

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ProgressBar
import androidx.appcompat.app.AppCompatActivity
import com.example.easytrip_test.R
import com.example.easytrip_test.login.SignUpActivity

class PreferenceActivity : AppCompatActivity() {

  private lateinit var progressBar: ProgressBar
  private var currentProgress: Int = 0

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // 타이틀바 없애기
    supportActionBar?.hide()

    // 레이아웃 설정
    val layout = FrameLayout(this)
    layout.layoutParams = ViewGroup.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT,
      ViewGroup.LayoutParams.MATCH_PARENT
    )
    setContentView(layout)

    // 프로그래스 바 설정
    progressBar = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal)
    progressBar.layoutParams = FrameLayout.LayoutParams(
      FrameLayout.LayoutParams.MATCH_PARENT,
      FrameLayout.LayoutParams.WRAP_CONTENT
    )
    progressBar.max = 100
    layout.addView(progressBar)

    // 상태바에 프로그래스 바 추가
    val attrs = window.attributes
    attrs.flags = attrs.flags or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
    window.attributes = attrs

    // 진행 상태 불러오기
    val sharedPref = getSharedPreferences("progress_prefs", Context.MODE_PRIVATE)
    currentProgress = sharedPref.getInt("progress", 0)
    progressBar.progress = currentProgress

    // 각 단계에 맞는 레이아웃 설정
    when (intent.getIntExtra("step", 1)) {
      1 -> {
        layout.addView(layoutInflater.inflate(R.layout.activity_preference_1, null))
        setupNextButton(layout, R.id.nextButton, 2)
      }
      2 -> {
        layout.addView(layoutInflater.inflate(R.layout.activity_preference_2, null))
        setupNextButton(layout, R.id.nextButton, 3)
      }
      3 -> {
        layout.addView(layoutInflater.inflate(R.layout.activity_preference_3, null))
        setupNextButton(layout, R.id.nextButton, 4)
      }
      4 -> {
        layout.addView(layoutInflater.inflate(R.layout.activity_preference_4, null))
        setupNextButton(layout, R.id.endButton, -1) // -1 means end
      }
    }
  }

  private fun setupNextButton(layout: ViewGroup, buttonId: Int, nextStep: Int) {
    val nextButton: Button = layout.findViewById(buttonId)
    nextButton.setOnClickListener {
      if (nextStep == -1) {
        // 마지막 단계에서 SignUpActivity로 이동
        val intent = Intent(this, SignUpActivity::class.java)
        startActivity(intent)
        finish()
      } else {
        // 프로그레스바 진행도 증가
        currentProgress += 25
        updateProgressBar(currentProgress)

        // 진행 상태 저장
        val sharedPref = getSharedPreferences("progress_prefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
          putInt("progress", currentProgress)
          apply()
        }

        // 다음 단계로 이동
        val intent = Intent(this, PreferenceActivity::class.java)
        intent.putExtra("step", nextStep)
        startActivity(intent)
        finish()
      }
    }
  }

  override fun onBackPressed() {
    if (currentProgress > 0) {
      // 프로그레스바 진행도 감소
      currentProgress -= 25
      updateProgressBar(currentProgress)

      // 진행 상태 저장
      val sharedPref = getSharedPreferences("progress_prefs", Context.MODE_PRIVATE)
      with(sharedPref.edit()) {
        putInt("progress", currentProgress)
        apply()
      }

      // 이전 단계로 이동
      val previousStep = intent.getIntExtra("step", 1) - 1
      if (previousStep > 0) {
        val intent = Intent(this, PreferenceActivity::class.java)
        intent.putExtra("step", previousStep)
        startActivity(intent)
        finish()
      } else {
        super.onBackPressed() // 맨 처음 단계에서는 기본 뒤로 가기 동작을 수행
      }
    } else {
      super.onBackPressed() // 맨 처음 단계에서는 기본 뒤로 가기 동작을 수행
    }
  }

  // ProgressBar 업데이트 메서드 추가
  private fun updateProgressBar(progress: Int) {
    progressBar.progress = progress
  }
}
