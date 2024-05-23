package com.example.easytrip_test.db

import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase

class Database private constructor() {

  private var mDB: SQLiteDatabase? = null
  private var mDBOpenHelper: DBOpenHelper? = null
  private lateinit var c: Cursor
  private lateinit var sql: String

  companion object {
    private var singletonDB: Database? = null

    @JvmStatic
    fun getInstance(): Database {
      if (singletonDB == null) {
        singletonDB = Database()
      }
      return singletonDB!!
    }
  }

  // 수정가능한 데이터베이스를 생성
  fun open(context: Context): SQLiteDatabase? {
    if (mDBOpenHelper == null) {
      mDBOpenHelper = DBOpenHelper(context)
      mDB = mDBOpenHelper!!.writableDatabase
    }
    return mDB
  }

  // 아이디 검색
  fun searchId(id: String): Cursor {
    sql = "SELECT id FROM ${mDBOpenHelper!!.DB_TABLE_USER} WHERE id = '$id'"
    // 입력한 아이디를 조건으로 테이블에서 아이디를 검색
    c = mDB!!.rawQuery(sql, null)
    c.moveToNext()
    return c // 커서 리턴
  }

  // 비밀번호 검색
  fun searchPw(id: String): Cursor {
    sql = "SELECT pw FROM ${mDBOpenHelper!!.DB_TABLE_USER} WHERE id = '$id'"
    // 입력한 아이디를 조건으로 테이블에서 비밀번호를 검색
    c = mDB!!.rawQuery(sql, null)
    c.moveToNext()
    return c // 커서 리턴
  }

  // 이름 검색
  fun searchName(id: String): Cursor {
    sql = "SELECT name FROM ${mDBOpenHelper!!.DB_TABLE_USER} WHERE id = '$id'"
    // 입력한 아이디를 조건으로 테이블에서 이름을 검색
    c = mDB!!.rawQuery(sql, null)
    c.moveToNext()
    return c // 커서 리턴
  }

  // 아이디 찾기
  fun findId(name: String, birth: String): Cursor {
    sql = "SELECT id FROM ${mDBOpenHelper!!.DB_TABLE_USER} WHERE name = '$name' AND birth = '$birth'"
    c = mDB!!.rawQuery(sql, null)
    c.moveToNext()
    return c
  }

  // 비밀번호 찾기
  fun findPw(id: String, name: String, birth: String): Cursor {
    sql = "SELECT pw FROM ${mDBOpenHelper!!.DB_TABLE_USER} WHERE id = '$id' AND name = '$name' AND birth = '$birth'"
    c = mDB!!.rawQuery(sql, null)
    c.moveToNext()
    return c
  }

  // 회원가입(데이터 추가)
  fun insert(db: SQLiteDatabase, id: String, pw: String, name: String, birth: String, gender: String) {
    val sql = "INSERT INTO ${mDBOpenHelper!!.DB_TABLE_USER} (id, pw, name, birth, gender) VALUES ('$id', '$pw', '$name', '$birth', '$gender')"
    db.execSQL(sql)
  }

  // 이름 수정
  fun updateName(db: SQLiteDatabase, name: String, id: String) {
    val sql = "UPDATE ${mDBOpenHelper!!.DB_TABLE_USER} SET name = '$name' WHERE id = '$id'"
    db.execSQL(sql)
  }

  // 비밀번호 수정
  fun updatePw(db: SQLiteDatabase, pw: String, id: String) {
    val sql = "UPDATE ${mDBOpenHelper!!.DB_TABLE_USER} SET pw = '$pw' WHERE id = '$id'"
    db.execSQL(sql)
  }
}
