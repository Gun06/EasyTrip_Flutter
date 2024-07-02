package com.example.easytrip

import android.content.Context
import android.app.Activity
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.os.Bundle
import android.util.Base64
import android.util.Log
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import net.daum.mf.map.api.MapPOIItem
import net.daum.mf.map.api.MapPoint
import net.daum.mf.map.api.MapView
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.security.MessageDigest

class MainActivity : FlutterActivity() {

  private lateinit var kakaoApiService: KakaoApiService
  private lateinit var mapView: MapView

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    getAppKeyHash() // 키 해시를 얻기 위해 함수 호출

    // Retrofit 초기화
    val retrofit = ApiClient.client
    kakaoApiService = retrofit.create(KakaoApiService::class.java)

    // 지도 초기화
    mapView = MapView(this)
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.easytrip/search").setMethodCallHandler { call, result ->
      when (call.method) {
        "search" -> {
          val query = call.arguments as String
          searchPlaces(query, result)
        }
        "zoomIn" -> {
          mapView.zoomIn(true)
          result.success(null)
        }
        "zoomOut" -> {
          mapView.zoomOut(true)
          result.success(null)
        }
        "moveToCurrentLocation" -> {
          moveToCurrentLocation(result)
        }
        "addMarker" -> {
          val location = call.argument<String>("location")
          addMarker(location, result)
        }
        else -> result.notImplemented()
      }
    }

    flutterEngine
      .platformViewsController
      .registry
      .registerViewFactory("KakaoMapView", KakaoMapFactory(this))
  }

  private fun getAppKeyHash() {
    try {
      val info = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
      for (signature in info.signatures) {
        val md = MessageDigest.getInstance("SHA")
        md.update(signature.toByteArray())
        val something = String(Base64.encode(md.digest(), 0))
        Log.e("Hash key", something)
      }
    } catch (e: Exception) {
      Log.e("name not found", e.toString())
    }
  }

  private fun searchPlaces(query: String, result: MethodChannel.Result) {
    val apiKey = "KakaoAK 06458f1a2d01e02bb731d2a37cfa6c85" // 여기에 실제 카카오 REST API 키로 바꾸세요
    val call = kakaoApiService.searchPlaces(apiKey, query, "127.027621", "37.497942", 500)
    call.enqueue(object : Callback<SearchResponse> {
      override fun onResponse(call: Call<SearchResponse>, response: Response<SearchResponse>) {
        if (response.isSuccessful) {
          val places = response.body()?.documents ?: emptyList()
          val placeNames = places.joinToString(", ") { it.placeName }
          result.success(placeNames)
        } else {
          result.error("SEARCH_ERROR", "Failed to search places", null)
        }
      }

      override fun onFailure(call: Call<SearchResponse>, t: Throwable) {
        result.error("SEARCH_ERROR", "Failed to search places", t.message)
      }
    })
  }

  private fun moveToCurrentLocation(result: MethodChannel.Result) {
    val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
    val locationProvider = LocationManager.GPS_PROVIDER
    try {
      val lastKnownLocation: Location? = locationManager.getLastKnownLocation(locationProvider)
      if (lastKnownLocation != null) {
        val latitude = lastKnownLocation.latitude
        val longitude = lastKnownLocation.longitude
        mapView.setMapCenterPoint(MapPoint.mapPointWithGeoCoord(latitude, longitude), true)
        result.success(null)
      } else {
        result.error("LOCATION_ERROR", "Failed to get current location", null)
      }
    } catch (e: SecurityException) {
      result.error("LOCATION_ERROR", "Location permission not granted", null)
    }
  }

  private fun addMarker(location: String?, result: MethodChannel.Result) {
    if (location != null) {
      val point = MapPoint.mapPointWithGeoCoord(37.537229, 127.005515) // 예시 좌표 사용
      val marker = MapPOIItem()
      marker.itemName = location
      marker.mapPoint = point
      marker.markerType = MapPOIItem.MarkerType.BluePin // 기본 마커 설정
      mapView.addPOIItem(marker)
      result.success(null)
    } else {
      result.error("MARKER_ERROR", "Location is null", null)
    }
  }
}

class KakaoMapFactory(private val activity: Activity) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
    return KakaoMapView(MapView(activity))
  }
}

class KakaoMapView(private val mapView: MapView) : PlatformView {
  override fun getView(): View {
    return mapView
  }

  override fun dispose() {}
}
