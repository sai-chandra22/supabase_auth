# Keep Kotlin text package and all its contents
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keep class kotlin.text.** { *; }
-keepclassmembers class kotlin.text.** { *; }
-keepnames class kotlin.text.** { *; }

# Keep HexFormat and related classes
-keep class kotlin.text.HexFormat { *; }
-keep class kotlin.text.HexExtensionsKt { *; }
-keep class kotlin.text.StringsKt { *; }

# Keep Persona SDK classes (since they're referencing the Kotlin classes)
-keep class com.withpersona.sdk2.** { *; }
-keepclassmembers class com.withpersona.sdk2.** { *; }

# Keep Kotlin reflection
-keep class kotlin.reflect.** { *; }
-keep class kotlin.jvm.internal.** { *; }

# Keep Kotlin standard library
-keep class kotlin.collections.** { *; }
-keep class kotlin.io.** { *; }

# Keep Kotlin coroutines
-keep class kotlinx.coroutines.** { *; }

# Keep all Kotlin metadata
-keepattributes *Annotation*, Signature, Exception
