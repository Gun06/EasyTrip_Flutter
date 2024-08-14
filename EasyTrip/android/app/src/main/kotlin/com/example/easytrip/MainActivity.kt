package com.example.easytrip

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.util.Base64
import android.util.Log
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import net.daum.mf.map.api.MapPOIItem
import net.daum.mf.map.api.MapPoint
import net.daum.mf.map.api.MapView
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.io.IOException
import java.security.MessageDigest

class MainActivity : FlutterActivity() {

  var mapView: MapView? = null
  private var startMarker: MapPOIItem? = null
  private var endMarker: MapPOIItem? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    getAppKeyHash()

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
            mapView?.zoomIn(true)
            result.success(null)
          }
          "zoomOut" -> {
            mapView?.zoomOut(true)
            result.success(null)
          }
          "moveToCurrentLocation" -> {
            mapView?.setMapCenterPoint(MapPoint.mapPointWithGeoCoord(37.5665, 126.9780), true)
            result.success(null)
          }
          "moveToLocation" -> {
            val latitude = (call.arguments as Map<*, *>?)?.get("latitude") as? Double
            val longitude = (call.arguments as Map<*, *>?)?.get("longitude") as? Double
            val isStartPoint = (call.arguments as Map<*, *>?)?.get("isStartPoint") as? Boolean

            if (latitude != null && longitude != null && isStartPoint != null) {
              mapView?.setMapCenterPoint(MapPoint.mapPointWithGeoCoord(latitude, longitude), true)
              addMarker(latitude, longitude, isStartPoint)
            }

            result.success(null)
          }
          "addMarker" -> {
            val latitude = (call.arguments as Map<*, *>?)?.get("latitude") as? Double
            val longitude = (call.arguments as Map<*, *>?)?.get("longitude") as? Double
            val isStartPoint = (call.arguments as Map<*, *>?)?.get("isStartPoint") as? Boolean

            if (latitude != null && longitude != null && isStartPoint != null) {
              addMarker(latitude, longitude, isStartPoint)
            }

            result.success(null)
          }
          "removeMapView" -> {
            removeMapView()
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun removeMapView() {
    if (mapView != null) {
      val parent = mapView!!.parent as? ViewGroup
      parent?.removeView(mapView)
      mapView = null
    }
  }

  override fun onDestroy() {
    super.onDestroy()
    mapView = null
  }

  fun addMarker(latitude: Double, longitude: Double, isStartPoint: Boolean) {
    val marker = MapPOIItem().apply {
      itemName = if (isStartPoint) "출발지" else "도착지"
      mapPoint = MapPoint.mapPointWithGeoCoord(latitude, longitude)
      markerType = MapPOIItem.MarkerType.CustomImage

      val bitmapResource = if (isStartPoint) R.drawable.start_marker else R.drawable.end_marker
      val bitmap = BitmapFactory.decodeResource(resources, bitmapResource)
      val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 150, 150, false)

      customImageBitmap = resizedBitmap
      isCustomImageAutoscale = false
      setCustomImageAnchor(0.5f, 1.0f)
    }

    if (isStartPoint) {
      startMarker?.let { mapView?.removePOIItem(it) }
      startMarker = marker
    } else {
      endMarker?.let { mapView?.removePOIItem(it) }
      endMarker = marker
    }

    mapView?.addPOIItem(marker)
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
    Log.d("searchPlaces", "Authorization: KakaoAK $apiKey")

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
    (activity as MainActivity).mapView = mapView

    val creationParams = args as Map<String, Any>
    val startLatitude = creationParams["startLatitude"] as? Double
    val startLongitude = creationParams["startLongitude"] as? Double
    val endLatitude = creationParams["endLatitude"] as? Double
    val endLongitude = creationParams["endLongitude"] as? Double

    if (startLatitude != null && startLongitude != null) {
      activity.addMarker(startLatitude, startLongitude, true)  // 출발지
    }
    if (endLatitude != null && endLongitude != null) {
      activity.addMarker(endLatitude, endLongitude, false)  // 도착지
    }

    return KakaoMapView(mapView)
  }
}

class KakaoMapView(private val mapView: MapView) : PlatformView {
  override fun getView(): View {
    return mapView
  }

  override fun dispose() {}
}
