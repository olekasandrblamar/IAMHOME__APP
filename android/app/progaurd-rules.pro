#-keep class com.walnutin.**.* {*;}
#-keep class com.walnutin.hardsdk.ProductNeed.entity.**.* {*;}
#-keep class com.google.gson.**.* {*;}

#-keepattributes Signature

#-keepattributes InnerClasses

# For using GSON @Expose annotation
#-keepattributes *Annotation*

# Gson specific classes
#-dontwarn sun.misc.**
#-keep class com.google.gson.stream.** { *; }

# Application classes that will be serialized/deserialized over Gson
#-keep class com.google.gson.examples.android.model.**.* { <fields>; }

# Prevent proguard from stripping interface information from TypeAdapter, TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
##-keep class * extends com.google.gson.TypeAdapter
#-keep class * implements com.google.gson.TypeAdapterFactory
#-keep class * implements com.google.gson.JsonSerializer
#-keep class * implements com.google.gson.JsonDeserializer
##-keep class com.google.gson.**.* {*;}
#-keep class com.cerashealth.ceras.**.* { *; }

#-dontskipnonpubliclibraryclassmembers
#-dontshrink
#-dontoptimize
#-printmapping build/libs/output/obfuscation.map
#-keepattributes
#-adaptclassstrings
#-dontnote
#-dontwarn

# Keep Android classes
#-keep class * extends android.**.* {
#    <fields>;
#    <methods>;
#}
#
#-keep class * extends android.**.* {
#    <fields>;
#    <methods>;
#}

# Keep serializable classes & fields
-keep class * extends java.io.Serializable {
    <fields>;
}

-keep class com.cerashealth.ceras.**.* {*;}

##---------------Begin: proguard configuration for Gson  ----------
# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.
-keepattributes Signature
-keepattributes InnerClasses

# For using GSON @Expose annotation
-keepattributes *Annotation*

# Gson specific classes
#-dontwarn sun.misc.**
-keep class com.google.gson.stream.**.* { *; }
-keep class com.google.gson.**.* { *; }
-keep class com.google.gson.* { *; }
-keep class com.walnutin.**.* {*;}
-keep class android.**.* {*;}
-keep class com.android.**.* {*;}

-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

-keepclassmembers enum com.google.android.datatransport.Priority {
    public static **[] values();
}

# Application classes that will be serialized/deserialized over Gson
#-keep class com.google.gson.examples.android.model.* { *; }

# Prevent proguard from stripping interface information from TypeAdapter, TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
#-keep class * extends com.google.gson.TypeAdapter
#-keep class * implements com.google.gson.TypeAdapterFactory
#-keep class * implements com.google.gson.JsonSerializer
#-keep class * implements com.google.gson.JsonDeserializer
#-keep class com.google.gson.**.* {*;}

# Prevent R8 from leaving Data object members always null
#-keepclassmembers,allowobfuscation class * {
#  @com.google.gson.annotations.SerializedName <fields>;
#}

##---------------End: proguard configuration for Gson  ----------

# Prevent R8 from leaving Data object members always null
#-keepclassmembers,allowobfuscation class * {
#  @com.google.gson.annotations.SerializedName <fields>;
#}

##---------------Begin: proguard configuration for Gson  ----------
# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.
#-keepattributes Signature
#-keepattributes InnerClasses

# Gson specific classes
#-keep class sun.misc.Unsafe { *; }
#-keep class com.google.gson.stream.** { *; }

# Application classes that will be serialized/deserialized over Gson
# -keep class mypersonalclass.data.model.** { *; }