-keep class com.google.android.gms.** { *; }
-keep class com.google.mlkit.** { *; }
-keep public class * extends com.google.mlkit.common.sdkinternal.MlKitContext { *; }

-dontwarn com.google.android.gms.**
-dontwarn com.google.mlkit.**