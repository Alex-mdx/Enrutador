# Reglas de ProGuard para release

# ---- Advertencias de librerías externas ----
-dontwarn org.conscrypt.**
-dontwarn com.huawei.**
-dontwarn com.huawei.hms.**

# Play Core (splitinstall/taks) solo se usa por deferred components del engine
# de Flutter, que esta app no usa. Sin este dontwarn, -keep de embedding abajo
# hace que R8 falle con "Missing classes detected while running R8".
-dontwarn com.google.android.play.core.**

# ---- Plugins de Flutter (suficientes con la opción 1: shared_preferences_android <2.5.0) ----
# getAll() usa method channels y no depende de clases Kotlin buscadas por nombre en runtime,
# así que no hacen falta reglas adicionales de kotlin.* (las de la opción 2 NO son necesarias).
-keep class io.flutter.plugins.** { *; }
-keepclassmembers class io.flutter.plugins.** { *; }

# ---- Flutter embedding / engine ----
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }