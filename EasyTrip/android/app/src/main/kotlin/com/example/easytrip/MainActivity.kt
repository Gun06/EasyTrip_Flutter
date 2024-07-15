package com.example.easytrip

import android.content.Context
import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import net.daum.mf.map.api.MapView
import net.daum.mf.map.api.MapPoint
import java.security.MessageDigest
import android.content.pm.PackageManager
import android.util.Base64

class MainActivity : FlutterActivity() {

  lateinit var mapView: MapView

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    getAppKeyHash() // 키 해시를 얻기 위해 함수 호출

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
          else -> result.notImplemented()
        }
      }
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
