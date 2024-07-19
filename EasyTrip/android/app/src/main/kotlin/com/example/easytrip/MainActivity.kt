package com.example.easytrip

import android.content.Context
import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import net.daum.mf.map.api.MapView
import net.daum.mf.map.api.MapPoint
import net.daum.mf.map.api.MapPOIItem
import net.daum.mf.map.api.MapPolyline
import java.security.MessageDigest
import android.content.pm.PackageManager
import android.util.Base64
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.IOException
import android.view.View
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {

  lateinit var mapView: MapView

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    getAppKeyHash() // 키 해시를 얻기 위해 함수 호출

    MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.easytrip/search")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "search" -> {
            val keyword = call.arguments as String
            searchPlaces(keyword, result)
          }
          else -> result.notImplemented()
        }
      }

    MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.easytrip/map")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "zoomIn" -> {
            mapView.zoomIn(true)
            result.success(null)
          }
          "zoomOut" -> {
            mapView.zoomOut(true)
            result.success(null)
          }
          "moveToCurrentLocation" -> {
            // 현재 위치로 이동하는 기능 구현
            mapView.setMapCenterPoint(MapPoint.mapPointWithGeoCoord(37.5665, 126.9780), true)
            result.success(null)
          }
          "moveToLocation" -> {
            val latitude = (call.arguments as Map<*, *>)["latitude"] as Double
            val longitude = (call.arguments as Map<*, *>)["longitude"] as Double
            mapView.setMapCenterPoint(MapPoint.mapPointWithGeoCoord(latitude, longitude), true)
            addMarker(latitude, longitude)
            result.success(null)
          }
          "addMarker" -> {
            val latitude = (call.arguments as Map<*, *>)["latitude"] as Double
            val longitude = (call.arguments as Map<*, *>)["longitude"] as Double
            addMarker(latitude, longitude)
            result.success(null)
          }
          "getRoute" -> {
            val startLatitude = (call.arguments as Map<*, *>)["startLatitude"] as Double
            val startLongitude = (call.arguments as Map<*, *>)["startLongitude"] as Double
            val endLatitude = (call.arguments as Map<*, *>)["endLatitude"] as Double
            val endLongitude = (call.arguments as Map<*, *>)["endLongitude"] as Double
            getRoute(startLatitude, startLongitude, endLatitude, endLongitude, result)
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun addMarker(latitude: Double, longitude: Double) {
    val marker = MapPOIItem()
    marker.itemName = "Selected Location"
    marker.mapPoint = MapPoint.mapPointWithGeoCoord(latitude, longitude)
    marker.markerType = MapPOIItem.MarkerType.CustomImage

    val bitmap = BitmapFactory.decodeResource(resources, R.drawable.custom_marker)
    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 150, 150, false)

    marker.customImageBitmap = resizedBitmap
    marker.isCustomImageAutoscale = false
    marker.setCustomImageAnchor(0.5f, 1.0f) // 마커 앵커 포인트 설정
    mapView.addPOIItem(marker)
  }

  private fun searchPlaces(keyword: String, result: MethodChannel.Result) {
    val client = OkHttpClient()
    val url = "https://dapi.kakao.com/v2/local/search/keyword.json?query=$keyword"
    val apiKey = "06458f1a2d01e02bb731d2a37cfa6c85"
    val request = Request.Builder()
      .url(url)
      .addHeader("Authorization", "KakaoAK $apiKey")
      .build()

    Log.d("searchPlaces", "Request URL: $url")
    Log.d("searchPlaces", "Authorization: KakaoAK $apiKey") // 인증 헤더 로그 출력

    client.newCall(request).enqueue(object : okhttp3.Callback {
      override fun onFailure(call: okhttp3.Call, e: IOException) {
        runOnUiThread {
          Log.e("searchPlaces", "Request failed: ${e.message}")
          result.error("ERROR", e.message, null)
        }
      }

      override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
        val responseData = response.body?.string()
        runOnUiThread {
          Log.d("searchPlaces", "Response code: ${response.code}")
          if (response.isSuccessful && responseData != null) {
            Log.d("searchPlaces", "Response successful: $responseData")
            result.success(responseData)
          } else {
            Log.e("searchPlaces", "Response failed: ${response.message}")
            result.error("ERROR", "Failed to get response", null)
          }
        }
      }
    })
  }

  private fun getRoute(startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, result: MethodChannel.Result) {
    val client = OkHttpClient()
    val url = "https://apis-navi.kakaomobility.com/v1/route"
    val apiKey = "06458f1a2d01e02bb731d2a37cfa6c85" // 실제 API 키를 넣어주세요

    val json = """
            {
                "origin": {
                    "x": "$startLongitude",
                    "y": "$startLatitude"
                },
                "destination": {
                    "x": "$endLongitude",
                    "y": "$endLatitude"
                },
                "priority": "RECOMMEND"
            }
        """
    val requestBody: RequestBody = json.toRequestBody("application/json".toMediaTypeOrNull())
    val request = Request.Builder()
      .url(url)
      .addHeader("Authorization", "KakaoAK $apiKey")
      .post(requestBody)
      .build()

    client.newCall(request).enqueue(object : okhttp3.Callback {
      override fun onFailure(call: okhttp3.Call, e: IOException) {
        runOnUiThread {
          result.error("ERROR", e.message, null)
        }
      }

      override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
        val responseData = response.body?.string()
        runOnUiThread {
          if (response.isSuccessful && responseData != null) {
            val jsonResponse = JSONObject(responseData)
            val routes = jsonResponse.getJSONArray("routes")
            if (routes.length() > 0) {
              val route = routes.getJSONObject(0)
              val sections = route.getJSONArray("sections")
              for (i in 0 until sections.length()) {
                val section = sections.getJSONObject(i)
                val roads = section.getJSONArray("roads")
                for (j in 0 until roads.length()) {
                  val road = roads.getJSONObject(j)
                  val vertexes = road.getJSONArray("vertexes")
                  val polyline = MapPolyline()
                  polyline.tag = 1000
                  polyline.lineColor = 0xFF0000FF.toInt()
                  for (k in 0 until vertexes.length() step 2) {
                    val longitude = vertexes.getDouble(k)
                    val latitude = vertexes.getDouble(k + 1)
                    polyline.addPoint(MapPoint.mapPointWithGeoCoord(latitude, longitude))
                  }
                  mapView.addPolyline(polyline)
                }
              }
              result.success(responseData)
            } else {
              result.error("ERROR", "No route found", null)
            }
          } else {
            result.error("ERROR", "Failed to get route", null)
          }
        }
      }
    })
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
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
}

class KakaoMapFactory(private val activity: Activity) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
    val mapView = MapView(activity)
    (activity as MainActivity).mapView = mapView // mapView를 MainActivity에 설정
    return KakaoMapView(mapView)
  }
}

class KakaoMapView(private val mapView: MapView) : PlatformView {
  override fun getView(): View {
    return mapView
  }

  override fun dispose() {}
}