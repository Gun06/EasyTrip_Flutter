package com.example.easytrip_test.db

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log

class DBOpenHelper(context: Context) : SQLiteOpenHelper(context, DB_NAME, null, DB_VERSION) {

  val DB_TABLE_USER: String
    get() {
      TODO()
    }

  override fun onCreate(db: SQLiteDatabase) {
    // 데이터베이스 필드 변경 시 앱 삭제 후 재설치하자!
    db.execSQL("CREATE TABLE $DB_TABLE_USER (" +
      "number INTEGER PRIMARY KEY AUTOINCREMENT," +
      "id TEXT," +
      "pw TEXT," +
      "name TEXT," +
      "birth TEXT," +
      "gender TEXT," +
      "phone TEXT)")
    Log.d("user Table", "유저 정보 테이블 생성")

    db.execSQL("CREATE TABLE $DB_TABLE_STUDENT_MENU (" +
      "number INTEGER PRIMARY KEY AUTOINCREMENT," +
      "code TEXT," +
      "name TEXT," +
      "img TEXT," +
      "price INTEGER," +
      "count INTEGER)")
    Log.d("menu Table", "메뉴 테이블 생성")

    db.execSQL("CREATE TABLE $DB_TABLE_CART (" +
      "number INTEGER PRIMARY KEY AUTOINCREMENT," +
      "code TEXT," +
      "name TEXT," +
      "img TEXT," +
      "price INTEGER," +
      "id TEXT," +
      "count INTEGER)")
    Log.d("Cart Table", "장바구니 테이블 생성")
  }

  override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
    // 업그레이드 로직
  }

  companion object {
    const val DB_NAME = "User.db"
    const val DB_TABLE_USER = "User" // 여기에 상수 정의
    const val DB_TABLE_STUDENT_MENU = "StudentMenu"
    const val DB_TABLE_CART = "Cart"
    const val DB_VERSION = 2
  }
}
