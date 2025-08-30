package com.example.enrutador

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ContentResolver
import android.net.Uri
import android.util.Log
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.enrutador/content_uri_reader"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "readContentUri" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        try {
                            // Asegurar que siempre devolvemos String
                            val content = readContentWithMemoryManagement(uriString)
                            result.success(content) // Siempre String
                        } catch (e: Exception) {
                            result.error("READ_ERROR", "Error reading content URI: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_URI", "URI is null", null)
                    }
                }
                "getFileSize" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        try {
                            val fileSize = getFileSize(uriString)
                            result.success(fileSize) // Int/Long
                        } catch (e: Exception) {
                            result.error("SIZE_ERROR", "Error getting file size: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_URI", "URI is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun readContentWithMemoryManagement(uriString: String): String {
        val uri = Uri.parse(uriString)
        val contentResolver: ContentResolver = applicationContext.contentResolver
        
        val fileSize = getFileSize(uriString)
        Log.d("MainActivity", "📊 Tamaño del archivo: ${fileSize / (1024 * 1024)} MB")
        
        // Estrategia según el tamaño del archivo
        return if (fileSize < 2 * 1024 * 1024) { // Menos de 2MB
            readContentDirectly(uriString)
        } else { // Más de 2MB, usar archivo temporal
            // Para archivos grandes, devolver el path del archivo temporal como string
            val tempFilePath = createTempFileWithContent(uriString)
            "file://$tempFilePath" // Devolver como string
        }
    }

    private fun readContentDirectly(uriString: String): String {
        val uri = Uri.parse(uriString)
        val contentResolver: ContentResolver = applicationContext.contentResolver
        
        return contentResolver.openInputStream(uri)?.use { inputStream ->
            BufferedReader(InputStreamReader(inputStream), 8192).use { reader ->
                val result = StringBuilder()
                val buffer = CharArray(8192)
                var charsRead: Int
                
                while (reader.read(buffer).also { charsRead = it } != -1) {
                    result.append(buffer, 0, charsRead)
                }
                result.toString() // Devolver contenido como String
            }
        } ?: throw Exception("Cannot open input stream")
    }

    private fun createTempFileWithContent(uriString: String): String {
        val uri = Uri.parse(uriString)
        val contentResolver: ContentResolver = applicationContext.contentResolver
        
        // Crear archivo temporal
        val tempFile = File.createTempFile("large_json", ".tmp", cacheDir)
        tempFile.deleteOnExit()

        Log.d("MainActivity", "📁 Archivo temporal: ${tempFile.absolutePath}")
        
        contentResolver.openInputStream(uri)?.use { inputStream ->
            FileOutputStream(tempFile).use { outputStream ->
                val buffer = ByteArray(8192)
                var bytesRead: Int
                var totalBytes = 0L
                
                while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                    outputStream.write(buffer, 0, bytesRead)
                    totalBytes += bytesRead
                    
                    // Log cada 5MB
                    if (totalBytes % (5 * 1024 * 1024) == 0L) {
                        Log.d("MainActivity", "📊 Procesados: ${totalBytes / (1024 * 1024)} MB")
                    }
                }
                
                Log.d("MainActivity", "✅ Total procesado: ${totalBytes} bytes")
            }
        } ?: throw Exception("Cannot open input stream")
        
        return tempFile.absolutePath // Devolver solo el path
    }

    private fun getFileSize(uriString: String): Long {
        val uri = Uri.parse(uriString)
        val contentResolver: ContentResolver = applicationContext.contentResolver
        
        contentResolver.openInputStream(uri)?.use { inputStream ->
            return try {
                inputStream.available().toLong()
            } catch (e: Exception) {
                // Si available() falla, usar método alternativo
                estimateFileSize(uriString)
            }
        } ?: throw Exception("Cannot open file for size estimation")
    }

    private fun estimateFileSize(uriString: String): Long {
        val uri = Uri.parse(uriString)
        val contentResolver: ContentResolver = applicationContext.contentResolver
        
        val cursor = contentResolver.query(uri, null, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val sizeIndex = it.getColumnIndex("_size")
                if (sizeIndex != -1) {
                    return it.getLong(sizeIndex)
                }
            }
        }
        return 0L
    }
}