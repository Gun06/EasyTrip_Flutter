package com.example.easytrip_test.ui.review

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class ReviewViewModel : ViewModel() {

  private val _text = MutableLiveData<String>().apply {
    value = "This is review Fragment"
  }
  val text: LiveData<String> = _text
}