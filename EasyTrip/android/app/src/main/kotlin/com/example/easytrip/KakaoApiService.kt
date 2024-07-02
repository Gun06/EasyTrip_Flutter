package com.example.easytrip

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Query

interface KakaoApiService {
  @GET("/v2/local/search/keyword.json")
  fun searchPlaces(
    @Header("Authorization") apiKey: String,
    @Query("query") query: String,
    @Query("x") longitude: String,
    @Query("y") latitude: String,
    @Query("radius") radius: Int
  ): Call<SearchResponse>
}
