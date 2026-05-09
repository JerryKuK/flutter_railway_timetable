package com.example.flutter_railway_timetable.widget.data.auth

import kotlinx.coroutines.runBlocking
import okhttp3.OkHttpClient
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

class KotlinTdxAuthManagerTest {

    private lateinit var server: MockWebServer

    @Before
    fun setUp() {
        server = MockWebServer()
        server.start()
    }

    @After
    fun tearDown() {
        server.shutdown()
    }

    @Test(expected = WidgetAuthException::class)
    fun `throws WidgetAuthException when clientId is empty`() {
        runBlocking {
            val manager = KotlinTdxAuthManager("", "secret", OkHttpClient())
            manager.getValidToken()
        }
    }

    @Test(expected = WidgetAuthException::class)
    fun `throws WidgetAuthException when clientSecret is empty`() {
        runBlocking {
            val manager = KotlinTdxAuthManager("id", "", OkHttpClient())
            manager.getValidToken()
        }
    }

    @Test
    fun `returns token from server response`() = runBlocking {
        server.enqueue(MockResponse()
            .setBody("""{"access_token":"test-token-123","expires_in":1800}""")
            .setResponseCode(200))

        val manager = KotlinTdxAuthManager(
            clientId = "test-id",
            clientSecret = "test-secret",
            httpClient = OkHttpClient(),
            tokenEndpoint = server.url("/token").toString()
        )

        val token = manager.getValidToken()
        assertEquals("test-token-123", token)
    }

    @Test
    fun `reuses cached token on second call`() = runBlocking {
        server.enqueue(MockResponse()
            .setBody("""{"access_token":"cached-token","expires_in":1800}""")
            .setResponseCode(200))

        val manager = KotlinTdxAuthManager(
            clientId = "test-id",
            clientSecret = "test-secret",
            httpClient = OkHttpClient(),
            tokenEndpoint = server.url("/token").toString()
        )

        val first = manager.getValidToken()
        val second = manager.getValidToken()

        assertEquals("cached-token", first)
        assertEquals("cached-token", second)
        assertEquals(1, server.requestCount) // only one HTTP call
    }
}
