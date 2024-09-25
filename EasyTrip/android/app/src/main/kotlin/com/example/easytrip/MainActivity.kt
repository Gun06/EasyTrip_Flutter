package com.example.easytrip

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Bundle
import android.util.Base64
import android.util.Log
import android.view.View
import android.view.ViewGroup
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.KakaoMapReadyCallback
import com.kakao.vectormap.KakaoMapSdk
import com.kakao.vectormap.LatLng
import com.kakao.vectormap.MapLifeCycleCallback
import com.kakao.vectormap.MapOverlay
import com.kakao.vectormap.MapView
import com.kakao.vectormap.camera.CameraUpdateFactory
import com.kakao.vectormap.label.Label
import com.kakao.vectormap.label.LabelLayer
import com.kakao.vectormap.label.LabelOptions
import com.kakao.vectormap.label.LabelStyle
import com.kakao.vectormap.label.LabelTextBuilder
import com.kakao.vectormap.route.RouteLineOptions
import com.kakao.vectormap.route.RouteLineSegment
import com.kakao.vectormap.route.RouteLineStyle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.io.IOException
import java.net.URLEncoder
import java.security.MessageDigest

class MainActivity : FlutterActivity() {

  var mapView: MapView? = null
  lateinit var kakaoMap: KakaoMap
  var isMapReady = false  // 지도가 준비되었는지 여부를 저장
  private lateinit var labelLayer: LabelLayer  // LabelLayer 추가
  private val labels = mutableListOf<Label>()  // Label 리스트
  private val labelOptionsList = mutableListOf<LabelOptions>()  // LabelOptions 리스트
  private var startAddLabel: Label? = null
  private var endAddLabel: Label? = null
  private val CHANNEL = "com.example.easytrip/map"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // KakaoMapSdk 초기화
    KakaoMapSdk.init(this, "5d2bc59246a7ef930e925c3535a64fb7")

    // MapView 초기화
    initializeMapView()

    // 지도 관련 MethodChannel
    MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.easytrip/map")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "zoomIn" -> {
            if (isMapReady) {
              kakaoMap.moveCamera(CameraUpdateFactory.zoomIn())
              result.success(null)
            } else {
              result.error("MAP_NOT_READY", "Map is not ready", null)
            }
          }
          "zoomOut" -> {
            if (isMapReady) {
              kakaoMap.moveCamera(CameraUpdateFactory.zoomOut())
              result.success(null)
            } else {
              result.error("MAP_NOT_READY", "Map is not ready", null)
            }
          }
          "moveToLocation" -> {
            val latitude = (call.arguments as Map<*, *>?)?.get("latitude") as? Double
            val longitude = (call.arguments as Map<*, *>?)?.get("longitude") as? Double
            if (latitude != null && longitude != null) {
              if (isMapReady) {
                moveToLocation(latitude, longitude)
                result.success(null)
              } else {
                result.error("MAP_NOT_READY", "Map is not ready", null)
              }
            } else {
              result.error("INVALID_ARGUMENTS", "Invalid coordinates", null)
            }
          }
          "addLabel" -> {
            val latitude = (call.arguments as Map<*, *>?)?.get("latitude") as? Double
            val longitude = (call.arguments as Map<*, *>?)?.get("longitude") as? Double
            val isStartPoint = (call.arguments as Map<*, *>?)?.get("isStartPoint") as? Boolean
            if (latitude != null && longitude != null) {
              if (isStartPoint != null) {
                addLabel(latitude, longitude, isStartPoint)
              } else {
                addLabel(latitude, longitude)
              }
            }
            result.success(null)
          }
          "removeMapView" -> {
            removeMapView()
            result.success(null)
          }
          "removeLabel" -> {
            startAddLabel?.let { removeLabel(it) }
            endAddLabel?.let { removeLabel(it) }
            result.success(null)
          }
          "setBicycleOverlay" -> {
            if (isMapReady) {
              setBicycleOverlay()
              result.success(null)
            } else {
              result.error("MAP_NOT_READY", "Map is not ready", null)
            }
          }
          "setRoadViewLineOverlay" -> {

            if (isMapReady) {
              setRoadViewLineOverlay()
              result.success(null)
            } else {
              result.error("INVALID_ARGUMENTS", "Invalid coordinates", null)
            }
          }
          "drawRouteLine" -> {
            val startLatLng = call.arguments as Map<String, Double>
            val startLatitude = startLatLng["startLatitude"] ?: 0.0
            val startLongitude = startLatLng["startLongitude"] ?: 0.0
            val endLatitude = startLatLng["endLatitude"] ?: 0.0
            val endLongitude = startLatLng["endLongitude"] ?: 0.0
            if (startLatitude != 0.0 && startLongitude != 0.0 && endLatitude != 0.0 && endLongitude != 0.0) {
              drawRouteLine(startLatitude, startLongitude, endLatitude, endLongitude)
              result.success(null)
            } else {
              result.error("INVALID_COORDINATES", "Invalid coordinates for route", null)
            }
          }
          "getCarRoute" -> {
            val startLat = call.argument<Double>("startLatitude") ?: 0.0
            val startLng = call.argument<Double>("startLongitude") ?: 0.0
            val endLat = call.argument<Double>("endLatitude") ?: 0.0
            val endLng = call.argument<Double>("endLongitude") ?: 0.0
            fetchCarRoute(startLat, startLng, endLat, endLng)
          }
          "getWalkingRoute" -> {
            val startLat = call.argument<Double>("startLatitude") ?: 0.0
            val startLng = call.argument<Double>("startLongitude") ?: 0.0
            val endLat = call.argument<Double>("endLatitude") ?: 0.0
            val endLng = call.argument<Double>("endLongitude") ?: 0.0
            fetchWalkingRoute(startLat, startLng, endLat, endLng)
          }
          "getBicycleRoute" -> {
            val startLat = call.argument<Double>("startLatitude") ?: 0.0
            val startLng = call.argument<Double>("startLongitude") ?: 0.0
            val endLat = call.argument<Double>("endLatitude") ?: 0.0
            val endLng = call.argument<Double>("endLongitude") ?: 0.0
            fetchBicycleRoute(startLat, startLng, endLat, endLng)
          }
          else -> result.notImplemented()
        }
      }

    // 검색 관련 MethodChannel 추가
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
  }

  // 자전거 도로 오버레이 활성화
  private fun setBicycleOverlay() {
    if (isMapReady) {
      // 1. MapOverlay를 사용하여 자전거 도로 오버레이 설정
      kakaoMap.showOverlay(MapOverlay.BICYCLE_ROAD)
      Log.d("KakaoMap", "Bicycle overlay enabled")
    } else {
      Log.e("KakaoMap", "BICYCLE_ROAD KakaoMap is not initialized")
    }
  }

  // 로드뷰 오버레이 활성화
  private fun setRoadViewLineOverlay() {
    if (isMapReady) {
      kakaoMap.showOverlay(MapOverlay.ROADVIEW_LINE)
      Log.d("KakaoMap", "Road view line overlay enabled")
    } else {
      Log.e("KakaoMap", "KakaoMap is not initialized")
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

  private fun initializeMapView() {
    mapView = MapView(this)
    mapView?.start(object : MapLifeCycleCallback() {
      override fun onMapDestroy() {
        Log.d("KakaoMap", "Map destroyed")
      }

      override fun onMapError(error: Exception) {
        Log.e("KakaoMap", "Map error: ${error.message}")
      }
    }, object : KakaoMapReadyCallback() {
      override fun onMapReady(map: KakaoMap) {
        kakaoMap = map
        isMapReady = true  // 지도 준비 완료 플래그 설정

        labelLayer = kakaoMap.labelManager?.getLayer() ?: run {
          Log.e("KakaoMap", "LabelLayer is not initialized")
          return
        }  // LabelLayer 초기화

        Log.d("KakaoMap", "KakaoMap is ready")
        moveToLocation(37.5665, 126.9780)
      }
    })
  }

  private fun moveToLocation(latitude: Double, longitude: Double) {
    if (isMapReady) {
      val position = LatLng.from(latitude, longitude)
      val cameraUpdate = CameraUpdateFactory.newCenterPosition(position)
      kakaoMap.moveCamera(cameraUpdate)
    } else {
      Log.e("KakaoMap", "KakaoMap is not initialized")
    }
  }

  // LabelLayer가 초기화되어 있지 않으면 초기화하는 메서드
  private fun initializeLabelLayerIfNeeded() {
    if (!::labelLayer.isInitialized && isMapReady) {
      labelLayer = kakaoMap.labelManager?.getLayer() ?: run {
        Log.e("KakaoMap", "Failed to initialize LabelLayer")
        return
      }
      Log.d("KakaoMap", "LabelLayer initialized")
    }
  }

  // 새로운 Label 추가
  private fun addLabel(latitude: Double, longitude: Double) {
    initializeLabelLayerIfNeeded() // labelLayer 초기화 확인

    if (isMapReady) {
      Log.d("KakaoMap", "Adding label at: $latitude, $longitude")
      val pos = LatLng.from(latitude, longitude)

      // BitmapFactory를 사용해 drawable을 비트맵으로 변환
      val bitmap = BitmapFactory.decodeResource(resources, R.drawable.custom_marker)
      val scaledBitmap = Bitmap.createScaledBitmap(bitmap, 100, 100, true)

      // LabelOptions 생성
      val labelOptions = LabelOptions.from(pos).setStyles(LabelStyle.from(scaledBitmap))

      // 레이블 추가하고 LabelOptions 저장
      labelLayer.addLabel(labelOptions)
      labelOptionsList.add(labelOptions)

      Log.d("KakaoMap", "Label added at: $latitude, $longitude")
    } else {
      Log.e("KakaoMap", "KakaoMap is not initialized")
    }
  }

  fun addLabel(latitude: Double, longitude: Double, isStartPoint: Boolean) {
    initializeLabelLayerIfNeeded() // labelLayer 초기화 확인

    if (!::labelLayer.isInitialized) {
      Log.e("KakaoMap", "LabelLayer is not initialized")
      return
    }

    // 좌표 설정
    val pos = LatLng.from(latitude, longitude)

    // "출발지"와 "도착지"에 맞는 비트맵 설정
    val bitmapResource = if (isStartPoint) R.drawable.start_marker else R.drawable.end_marker
    val bitmap = BitmapFactory.decodeResource(resources, bitmapResource)
    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 150, 150, false)

    // LabelTextBuilder를 사용하여 텍스트 설정
    val labelTextBuilder = LabelTextBuilder().setTexts(if (isStartPoint) "출발지" else "도착지")

    // LabelStyle 생성 및 텍스트 스타일 추가
    val labelStyle = LabelStyle.from(resizedBitmap).setTextStyles(20, Color.BLACK)

    // LabelOptions 생성
    val labelOptions = LabelOptions.from(pos)
      .setTexts(labelTextBuilder) // LabelTextBuilder를 사용하여 텍스트 설정
      .setStyles(labelStyle)

    // 이전 라벨 제거 후 새로운 라벨 추가 (출발지 또는 도착지)
    if (isStartPoint) {
      startAddLabel?.let { labelLayer.remove(it) }
      startAddLabel = labelLayer.addLabel(labelOptions)
    } else {
      endAddLabel?.let { labelLayer.remove(it) }
      endAddLabel = labelLayer.addLabel(labelOptions)
    }

    Log.d("KakaoMap", "Label added at: $latitude, $longitude")
  }

  // 모든 Label 삭제
  private fun removeLabel(label: Label) {
    if (isMapReady && ::labelLayer.isInitialized) {
      kakaoMap.labelManager?.clearAll()  // 특정 라벨만 제거할 수 없다면 레이어 전체를 초기화
      labels.remove(label)   // 리스트에서 해당 라벨 제거
      Log.d("KakaoMap", "Label removed: ${label.labelId}")
    } else {
      Log.e("KakaoMap", "KakaoMap or LabelLayer is not initialized")
    }
  }

  override fun onResume() {
    super.onResume()
    if (isMapReady) {
      // 복귀 시 이전에 추가된 레이블들을 다시 추가
      restoreLabels()
    }
  }

  // 모든 레이블을 복구하는 함수
  private fun restoreLabels() {
    for (labelOptions in labelOptionsList) {
      labelLayer.addLabel(labelOptions)  // 저장된 LabelOptions를 사용하여 레이블 복구
    }
    Log.d("KakaoMap", "All labels restored after onResume")
  }

  // 검색 기능 구현
  private fun searchPlaces(keyword: String, result: MethodChannel.Result) {
    val client = OkHttpClient()
    val url = "https://dapi.kakao.com/v2/local/search/keyword.json?query=${URLEncoder.encode(keyword, "UTF-8")}"
    val apiKey = "06458f1a2d01e02bb731d2a37cfa6c85"  // 여기에 본인의 REST API 키를 입력하세요
    val request = Request.Builder()
      .url(url)
      .addHeader("Authorization", "KakaoAK $apiKey")
      .build()

    Log.d("searchPlaces", "Request URL: $url")

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

  private fun drawRouteLine(startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double) {
    if (isMapReady) {
      val startLatLng = LatLng.from(startLatitude, startLongitude)
      val endLatLng = LatLng.from(endLatitude, endLongitude)

      // 1. RouteLine 스타일 설정 (lineWidth: Float, lineColor: Int)
      val routeLineStyle = RouteLineStyle.from(16f, Color.BLUE)  // 두께 16, 파란색 경로 라인

      // 2. RouteLineSegment 생성
      val segment = RouteLineSegment.from(listOf(startLatLng, endLatLng)).setStyles(routeLineStyle)

      // 3. RouteLineOptions 생성 (segments: List<RouteLineSegment>)
      val routeLineOptions = RouteLineOptions.from(listOf(segment))

      // 4. RouteLineLayer 가져오기
      val layer = kakaoMap.getRouteLineManager()?.getLayer()

      // 5. RouteLine 추가
      val routeLine = layer?.addRouteLine(routeLineOptions)

      Log.d("KakaoMap", "Route line added from $startLatitude, $startLongitude to $endLatitude, $endLongitude")
    } else {
      Log.e("KakaoMap", "Map is not ready to draw route line")
    }
  }



  fun fetchWalkingRoute(startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double) {
    val client = OkHttpClient()
    val url = "https://apis-navi.kakaomobility.com/v1/directions?origin=${startLongitude},${startLatitude}&destination=${endLongitude},${endLatitude}&priority=RECOMMEND&roadDetails=false&vehicleType=1" // vehicleType=1은 도보
//    val url = "https://apis-navi.kakaomobility.com/v1/directions?origin=$startLongitude,$startLatitude&destination=$endLongitude,$endLatitude"
    val request = Request.Builder()
      .url(url)
      .addHeader("Authorization", "KakaoAK 06458f1a2d01e02bb731d2a37cfa6c85")  // REST API 키 입력
      .build()

    client.newCall(request).enqueue(object : okhttp3.Callback {
      override fun onFailure(call: okhttp3.Call, e: IOException) {
        runOnUiThread {
          Log.e("RouteLine", "Failed to get route: ${e.message}")
        }
      }

      override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
        if (!response.isSuccessful) {
          Log.e("RouteLine", "Failed to get route: ${response.message}")
          return
        }

        val responseData = response.body?.string()
        Log.d("RouteLine", "Response Data: $responseData") // 응답 데이터를 로그로 출력

        val jsonResponse = JSONObject(responseData)
        val routes = jsonResponse.getJSONArray("routes")
        if (routes.length() == 0) {
          Log.e("RouteLine", "No routes found in the response")
          return
        }

        // 경로 데이터에서 vertexes를 추출
        val routePoints = routes.getJSONObject(0).getJSONArray("sections").getJSONObject(0).getJSONArray("roads")

        // 경로 점들을 담을 리스트 생성
        val points = mutableListOf<LatLng>()
        for (i in 0 until routePoints.length()) {
          val road = routePoints.getJSONObject(i)
          val vertexes = road.getJSONArray("vertexes")

          // vertexes 배열은 [lng1, lat1, lng2, lat2, ...] 형식으로 구성됨
          for (j in 0 until vertexes.length() step 2) {
            val lng = vertexes.getDouble(j)
            val lat = vertexes.getDouble(j + 1)
            points.add(LatLng.from(lat, lng))
          }
        }

        runOnUiThread {
          if (points.isNotEmpty()) {
            // RouteLineSegment 생성
            val routeLineStyle = RouteLineStyle.from(10f, Color.BLUE)  // 경로 라인 스타일 설정
            val segment = RouteLineSegment.from(points).setStyles(routeLineStyle)

            // RouteLineOptions 생성
            val routeLineOptions = RouteLineOptions.from(listOf(segment))

            // RouteLineLayer에 경로 추가
            val layer = kakaoMap.getRouteLineManager()?.getLayer()
            layer?.addRouteLine(routeLineOptions)

            // 경로가 잘 보이도록 카메라 이동
            moveToFitRoute(points.toTypedArray())  // 경로 전체를 화면에 맞춤
          } else {
            Log.e("RouteLine", "Not enough points to draw a route")
          }
        }
      }
    })
  }

  fun fetchCarRoute(startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double) {
    val client = OkHttpClient()
    val url = "https://apis-navi.kakaomobility.com/v1/directions?origin=${startLongitude},${startLatitude}&destination=${endLongitude},${endLatitude}&priority=RECOMMEND&roadDetails=false&vehicleType=2" // vehicleType=2는 차량

    val request = Request.Builder()
      .url(url)
      .addHeader("Authorization", "KakaoAK 06458f1a2d01e02bb731d2a37cfa6c85")  // REST API 키 입력
      .build()

    client.newCall(request).enqueue(object : okhttp3.Callback {
      override fun onFailure(call: okhttp3.Call, e: IOException) {
        runOnUiThread {
          Log.e("RouteLine", "Failed to get car route: ${e.message}")
        }
      }

      override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
        if (!response.isSuccessful) {
          Log.e("RouteLine", "Failed to get car route: ${response.message}")
          return
        }

        val responseData = response.body?.string()
        Log.d("RouteLine", "Response Data: $responseData") // 응답 데이터를 로그로 출력

        val jsonResponse = JSONObject(responseData)
        val routes = jsonResponse.getJSONArray("routes")
        if (routes.length() == 0) {
          Log.e("RouteLine", "No routes found in the response")
          return
        }

        // 경로 데이터에서 vertexes를 추출
        val routePoints = routes.getJSONObject(0).getJSONArray("sections").getJSONObject(0).getJSONArray("roads")

        // 경로 점들을 담을 리스트 생성
        val points = mutableListOf<LatLng>()
        for (i in 0 until routePoints.length()) {
          val road = routePoints.getJSONObject(i)
          val vertexes = road.getJSONArray("vertexes")

          // vertexes 배열은 [lng1, lat1, lng2, lat2, ...] 형식으로 구성됨
          for (j in 0 until vertexes.length() step 2) {
            val lng = vertexes.getDouble(j)
            val lat = vertexes.getDouble(j + 1)
            points.add(LatLng.from(lat, lng))
          }
        }

        runOnUiThread {
          if (points.isNotEmpty()) {
            // RouteLineSegment 생성
            val routeLineStyle = RouteLineStyle.from(10f, Color.BLUE)  // 경로 라인 스타일 설정
            val segment = RouteLineSegment.from(points).setStyles(routeLineStyle)

            // RouteLineOptions 생성
            val routeLineOptions = RouteLineOptions.from(listOf(segment))

            // RouteLineLayer에 경로 추가
            val layer = kakaoMap.getRouteLineManager()?.getLayer()
            layer?.addRouteLine(routeLineOptions)

            // 경로가 잘 보이도록 카메라 이동
            moveToFitRoute(points.toTypedArray())  // 경로 전체를 화면에 맞춤
          } else {
            Log.e("RouteLine", "Not enough points to draw a car route")
          }
        }
      }
    })
  }

  fun fetchBicycleRoute(startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double) {
    val client = OkHttpClient()
    val url = "https://apis-navi.kakaomobility.com/v1/directions?origin=${startLongitude},${startLatitude}&destination=${endLongitude},${endLatitude}&priority=RECOMMEND&roadDetails=false&vehicleType=3" // vehicleType=3은 자전거

    val request = Request.Builder()
      .url(url)
      .addHeader("Authorization", "KakaoAK 06458f1a2d01e02bb731d2a37cfa6c85")  // REST API 키 입력
      .build()

    client.newCall(request).enqueue(object : okhttp3.Callback {
      override fun onFailure(call: okhttp3.Call, e: IOException) {
        runOnUiThread {
          Log.e("RouteLine", "Failed to get bicycle route: ${e.message}")
        }
      }

      override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
        if (!response.isSuccessful) {
          Log.e("RouteLine", "Failed to get bicycle route: ${response.message}")
          return
        }

        val responseData = response.body?.string()
        Log.d("RouteLine", "Response Data: $responseData") // 응답 데이터를 로그로 출력

        val jsonResponse = JSONObject(responseData)
        val routes = jsonResponse.getJSONArray("routes")
        if (routes.length() == 0) {
          Log.e("RouteLine", "No routes found in the response")
          return
        }

        // 경로 데이터에서 vertexes를 추출
        val routePoints = routes.getJSONObject(0).getJSONArray("sections").getJSONObject(0).getJSONArray("roads")

        // 경로 점들을 담을 리스트 생성
        val points = mutableListOf<LatLng>()
        for (i in 0 until routePoints.length()) {
          val road = routePoints.getJSONObject(i)
          val vertexes = road.getJSONArray("vertexes")

          // vertexes 배열은 [lng1, lat1, lng2, lat2, ...] 형식으로 구성됨
          for (j in 0 until vertexes.length() step 2) {
            val lng = vertexes.getDouble(j)
            val lat = vertexes.getDouble(j + 1)
            points.add(LatLng.from(lat, lng))
          }
        }

        runOnUiThread {
          if (points.isNotEmpty()) {
            // RouteLineSegment 생성
            val routeLineStyle = RouteLineStyle.from(10f, Color.BLUE)  // 경로 라인 스타일 설정
            val segment = RouteLineSegment.from(points).setStyles(routeLineStyle)

            // RouteLineOptions 생성
            val routeLineOptions = RouteLineOptions.from(listOf(segment))

            // RouteLineLayer에 경로 추가
            val layer = kakaoMap.getRouteLineManager()?.getLayer()
            layer?.addRouteLine(routeLineOptions)

            // 경로가 잘 보이도록 카메라 이동
            moveToFitRoute(points.toTypedArray())  // 경로 전체를 화면에 맞춤
          } else {
            Log.e("RouteLine", "Not enough points to draw a bicycle route")
          }
        }
      }
    })
  }

  // 경로 전체를 화면에 맞추기 위한 카메라 이동 함수
  private fun moveToFitRoute(points: Array<LatLng>) {
    if (isMapReady) {
      val cameraUpdate = CameraUpdateFactory.fitMapPoints(points)  // 경로 좌표 배열을 사용하여 카메라 업데이트
      kakaoMap.moveCamera(cameraUpdate)
    } else {
      Log.e("KakaoMap", "KakaoMap is not initialized")
    }
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

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    flutterEngine
      .platformViewsController
      .registry
      .registerViewFactory("KakaoMapView", KakaoMapFactory(this))
  }
}

class KakaoMapFactory(private val activity: Activity) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
    val mapView = MapView(activity)
    (activity as MainActivity).mapView = mapView

    mapView.start(object : MapLifeCycleCallback() {
      override fun onMapDestroy() {
        Log.d("KakaoMap", "Map destroyed")
      }

      override fun onMapError(error: Exception) {
        Log.e("KakaoMap", "Map error: ${error.message}")
      }
    }, object : KakaoMapReadyCallback() {
      override fun onMapReady(map: KakaoMap) {
        (activity as MainActivity).kakaoMap = map
        (activity as MainActivity).isMapReady = true  // 지도 준비 완료 플래그 설정
        Log.d("KakaoMap", "KakaoMap is ready")
      }
    })
    val creationParams = args as Map<String, Any>
    val startLatitude = creationParams["startLatitude"] as? Double
    val startLongitude = creationParams["startLongitude"] as? Double
    val endLatitude = creationParams["endLatitude"] as? Double
    val endLongitude = creationParams["endLongitude"] as? Double

    if (startLatitude != null && startLongitude != null) {
      activity.addLabel(startLatitude, startLongitude, true)  // 출발지
    }
    if (endLatitude != null && endLongitude != null) {
      activity.addLabel(endLatitude, endLongitude, false)  // 도착지
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
