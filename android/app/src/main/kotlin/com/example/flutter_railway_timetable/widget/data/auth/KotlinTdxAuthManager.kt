package com.example.flutter_railway_timetable.widget.data.auth

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import okhttp3.FormBody
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class KotlinTdxAuthManager(
    private val clientId: String,
    private val clientSecret: String,
    private val httpClient: OkHttpClient = OkHttpClient(),
    private val tokenEndpoint: String = TOKEN_ENDPOINT
) {
    private val mutex = Mutex()
    private var cachedToken: String? = null
    private var tokenExpiresAt: Long = 0L

    suspend fun getValidToken(): String {
        if (clientId.isBlank() || clientSecret.isBlank()) {
            throw WidgetAuthException("ERR_NO_CREDENTIALS")
        }
        return mutex.withLock {
            val now = System.currentTimeMillis()
            if (cachedToken != null && now < tokenExpiresAt) {
                cachedToken!!
            } else {
                fetchToken()
            }
        }
    }

    private suspend fun fetchToken(): String = withContext(Dispatchers.IO) {
        val body = FormBody.Builder()
            .add("grant_type", "client_credentials")
            .add("client_id", clientId)
            .add("client_secret", clientSecret)
            .build()

        val request = Request.Builder()
            .url(tokenEndpoint)
            .post(body)
            .build()

        val response = httpClient.newCall(request).execute()
        val responseBody = response.body?.string()
            ?: throw WidgetAuthException("ERR_EMPTY_RESPONSE")

        if (!response.isSuccessful) {
            throw WidgetAuthException("ERR_HTTP_${response.code}")
        }

        val json = JSONObject(responseBody)
        val token = json.getString("access_token")
        val expiresIn = json.optLong("expires_in", 1800L)

        cachedToken = token
        tokenExpiresAt = System.currentTimeMillis() +
                TimeUnit.SECONDS.toMillis(expiresIn - 60)

        token
    }

    companion object {
        private const val TOKEN_ENDPOINT =
            "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token"
    }
}
