package com.example.easytrip_test.preference

import android.content.Context
import android.content.Intent
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.example.easytrip_test.R
import com.example.easytrip_test.login.SignUpActivity

class PreferenceActivity : AppCompatActivity() {

  private lateinit var progressBar: ProgressBar
  private var currentProgress: Int = 0
  private val selectedImages = mutableListOf<Int>()
  private val selectedFoods = mutableListOf<Int>()
  private val selectedAccommodations = mutableListOf<Int>()
  private lateinit var nextButton: Button
  private lateinit var layout: FrameLayout

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // 타이틀바 없애기
    supportActionBar?.hide()

    // 레이아웃 설정
    layout = FrameLayout(this)
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
    setupStepLayout(intent.getIntExtra("step", 1))

    // Back press callback
    onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
      override fun handleOnBackPressed() {
        if (currentProgress > 0) {
          // 프로그래스바 진행도 감소
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
            setupStepLayout(previousStep)
          } else {
            isEnabled = false
            onBackPressedDispatcher.onBackPressed()
          }
        } else {
          isEnabled = false
          onBackPressedDispatcher.onBackPressed()
        }
      }
    })
  }

  private fun setupStepLayout(step: Int) {
    layout.removeAllViews()

    // 각 단계 레이아웃 설정
    when (step) {
      1 -> {
        val stepLayout = layoutInflater.inflate(R.layout.activity_preference_1, layout, false) as ViewGroup
        layout.addView(stepLayout)
        setupBackButton(stepLayout)
        setupNextButton(stepLayout, R.id.nextButton1, 2, true) // 초기 배경색을 blue_dark로 설정
      }
      2 -> {
        val stepLayout = layoutInflater.inflate(R.layout.activity_preference_2, layout, false) as ViewGroup
        layout.addView(stepLayout)
        setupNextButton(stepLayout, R.id.nextButton2, 3, false) // 초기 배경색을 darker_gray로 설정
        setupImageSelection(stepLayout, R.id.nextButton2, selectedImages, 4) // 4개 선택 시 활성화
      }
      3 -> {
        val stepLayout = layoutInflater.inflate(R.layout.activity_preference_3, layout, false) as ViewGroup
        layout.addView(stepLayout)
        setupNextButton(stepLayout, R.id.nextButton3, 4, false) // 초기 배경색을 darker_gray로 설정
        setupImageSelection(stepLayout, R.id.nextButton3, selectedFoods, 5) // 5개 선택 시 활성화
      }
      4 -> {
        val stepLayout = layoutInflater.inflate(R.layout.activity_preference_4, layout, false) as ViewGroup
        layout.addView(stepLayout)
        setupNextButton(stepLayout, R.id.endButton, -1, false) // 초기 배경색을 darker_gray로 설정
        setupButtonSelection(stepLayout, R.id.endButton, selectedAccommodations, 3) // 3개 선택 시 활성화
      }
    }

    // 프로그래스바를 항상 맨 위에 유지
    layout.addView(progressBar)
  }

  private fun setupNextButton(layout: ViewGroup, buttonId: Int, nextStep: Int, isInitialEnabled: Boolean) {
    nextButton = layout.findViewById(buttonId)
    nextButton.isEnabled = isInitialEnabled // 초기 버튼 활성화 상태 설정
    if (isInitialEnabled) {
      nextButton.setBackgroundColor(ContextCompat.getColor(this, R.color.blue_dark))
    } else {
      nextButton.setBackgroundColor(ContextCompat.getColor(this, android.R.color.darker_gray))
    }
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
        setupStepLayout(nextStep)
      }
    }
  }

  private fun setupBackButton(layout: ViewGroup) {
    val imageclose: ImageButton = layout.findViewById(R.id.imageclose)
    imageclose.setOnClickListener {
      onBackPressedDispatcher.onBackPressed()
    }
  }

  private fun setupImageSelection(layout: ViewGroup, nextButtonId: Int, selectionList: MutableList<Int>, requiredSelections: Int) {
    val imageIds = listOf(R.id.image1, R.id.image2, R.id.image3, R.id.image4, R.id.food1, R.id.food2, R.id.food3, R.id.food4, R.id.food5)
    for (imageId in imageIds) {
      val imageView: ImageView? = layout.findViewById(imageId)
      imageView?.setOnClickListener {
        handleSelection(imageView, imageId, nextButtonId, selectionList, requiredSelections)
      }
    }
  }

  private fun setupButtonSelection(layout: ViewGroup, nextButtonId: Int, selectionList: MutableList<Int>, requiredSelections: Int) {
    val buttonIds = listOf(R.id.hotel, R.id.motel, R.id.guestHouse)
    for (buttonId in buttonIds) {
      val button: Button? = layout.findViewById(buttonId)
      button?.setOnClickListener {
        handleButtonSelection(button, buttonId, nextButtonId, selectionList, requiredSelections)
      }
    }
  }

  private fun handleButtonSelection(button: Button, buttonId: Int, nextButtonId: Int, selectionList: MutableList<Int>, requiredSelections: Int) {
    if (!selectionList.contains(buttonId)) {
      selectionList.add(buttonId)
      button.setBackgroundResource(R.drawable.bg_button_round)
    } else {
      selectionList.remove(buttonId)
      button.setBackgroundColor(ContextCompat.getColor(this, R.color.WhiteSmoke))
    }

    val nextButton: Button = findViewById(nextButtonId)
    if (selectionList.size >= requiredSelections) {
      nextButton.isEnabled = true
      nextButton.setBackgroundColor(ContextCompat.getColor(this, R.color.blue_dark))
    } else {
      nextButton.isEnabled = false
      nextButton.setBackgroundColor(ContextCompat.getColor(this, android.R.color.darker_gray))
    }
  }

  private fun handleSelection(view: View, viewId: Int, nextButtonId: Int, selectionList: MutableList<Int>, requiredSelections: Int) {
    if (!selectionList.contains(viewId)) {
      selectionList.add(viewId)
      val colorMatrix = ColorMatrix()
      colorMatrix.setSaturation(0f)
      val filter = ColorMatrixColorFilter(colorMatrix)
      if (view is ImageView) {
        view.colorFilter = filter
        view.imageAlpha = 100 // 반투명 효과
      } else if (view is TextView) {
        view.background.colorFilter = filter
      }
    } else {
      selectionList.remove(viewId)
      if (view is ImageView) {
        view.clearColorFilter()
        view.imageAlpha = 255 // 원래 상태로
      } else if (view is TextView) {
        view.background.clearColorFilter()
      }
    }

    val nextButton: Button = findViewById(nextButtonId)
    if (selectionList.size >= requiredSelections) {
      nextButton.isEnabled = true
      nextButton.setBackgroundColor(ContextCompat.getColor(this, R.color.blue_dark))
    } else {
      nextButton.isEnabled = false
      nextButton.setBackgroundColor(ContextCompat.getColor(this, android.R.color.darker_gray))
    }
  }

  // ProgressBar 업데이트 메서드 추가
  private fun updateProgressBar(progress: Int) {
    progressBar.progress = progress
  }
}

//2

