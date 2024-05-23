package com.example.easytrip_test.popUp

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.MotionEvent
import android.view.View
import android.view.Window
import android.widget.TextView
import com.example.easytrip_test.R
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream

class PopupActivity_1 : Activity() {
  private val closePopup1 = "Close Popup_1"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    requestWindowFeature(Window.FEATURE_NO_TITLE) // 타이틀바 지우기
    setContentView(R.layout.activity_popup_1)

    val helloTxt: TextView = findViewById(R.id.text_1)
    helloTxt.text = readTxt()
  }

  private fun readTxt(): String? {
    var data: String? = null
    val inputStream: InputStream = resources.openRawResource(R.raw.text_1)
    val byteArrayOutputStream = ByteArrayOutputStream()

    try {
      var i: Int = inputStream.read()
      while (i != -1) {
        byteArrayOutputStream.write(i)
        i = inputStream.read()
      }

      data = String(byteArrayOutputStream.toByteArray(), charset("MS949"))
      inputStream.close()
    } catch (e: IOException) {
      e.printStackTrace()
    }
    return data
  }

  fun mOnClose(v: View) {
    // 데이터 전달하기
    val intent = Intent()
    intent.putExtra("result_1", closePopup1)
    setResult(RESULT_OK, intent)

    // 액티비티(팝업) 닫기
    finish()
  }

  override fun onTouchEvent(event: MotionEvent): Boolean {
    // 바깥레이어 클릭시 안닫히게
    return event.action != MotionEvent.ACTION_OUTSIDE
  }

  override fun onBackPressed() {
    // 안드로이드 백버튼 막기
    return
  }
}
