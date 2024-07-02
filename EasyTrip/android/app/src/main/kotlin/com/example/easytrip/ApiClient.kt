package com.example.easytrip

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object ApiClient {
  private const val BASE_URL = "https://dapi.kakao.com"

  val client: Retrofit by lazy {
    Retrofit.Builder()
      .baseUrl(BASE_URL)
      .addConverterFactory(GsonConverterFactory.create())
      .build()
  }
}
