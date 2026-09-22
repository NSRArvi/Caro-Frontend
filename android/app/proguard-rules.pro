# Flutter / Dart
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Stripe SDK push provisioning classes
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# Gson keep model classes (if using Stripe JSON parsing)
-keep class * extends com.stripe.android.model.StripeModel { *; }

# Keep annotations
-keepattributes *Annotation*

# Ignore missing Play Core classes (Fixes R8 missing class error)
-dontwarn com.google.android.play.core.**

# Stripe Specific Rules
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Firebase Specific Rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
