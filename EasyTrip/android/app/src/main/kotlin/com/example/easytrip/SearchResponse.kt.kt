package com.example.easytrip

import com.google.gson.annotations.SerializedName

data class SearchResponse(
  @SerializedName("documents")
  val places: List<Place>
) {
  data class Place(
    @SerializedName("place_name")
    val name: String,
    @SerializedName("address_name")
    val address: String,
    @SerializedName("x")
    val longitude: String,
    @SerializedName("y")
    val latitude: String
  )
}
