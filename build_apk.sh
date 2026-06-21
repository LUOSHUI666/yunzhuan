#!/bin/bash
# Minimal WebView APK Builder - Zero dependencies
# Only needs: aapt2, javac, d8, zipalign, apksigner
set -e

WORK=/home/luoshui1/projects/yunzhuan
ANDROID_HOME=~/android-sdk
JAVA_HOME=~/jdk17
BT=$ANDROID_HOME/build-tools/36.0.0
PLAT=$ANDROID_HOME/platforms/android-36
export PATH=$JAVA_HOME/bin:$BT:$PATH

TMP=/tmp/yunzhuan-apk
rm -rf $TMP && mkdir -p $TMP/res/values $TMP/java/com/luoshui/yunzhuan $TMP/assets/public

# Copy web assets
cp $WORK/index.html $WORK/manifest.json $WORK/sw.js $WORK/icon-*.svg $TMP/assets/public/

# AndroidManifest.xml (minimal)
cat > $TMP/AndroidManifest.xml << 'XML'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.luoshui.yunzhuan">
    <uses-sdk android:minSdkVersion="21" android:targetSdkVersion="34" android:compileSdkVersion="36"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <application android:label="云篆" android:theme="@android:style/Theme.Black.NoTitleBar.Fullscreen"
        android:hardwareAccelerated="true" android:supportsRtl="true"
        android:allowBackup="false" android:extractNativeLibs="false">
        <activity android:name=".MainActivity" android:exported="true"
            android:configChanges="orientation|screenSize|keyboardHidden">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
XML

# strings.xml
cat > $TMP/res/values/strings.xml << 'XML'
<?xml version="1.0" encoding="utf-8"?>
<resources><string name="app_name">云篆</string></resources>
XML

# MainActivity.java - loads PWA in WebView
cat > $TMP/java/com/luoshui/yunzhuan/MainActivity.java << 'JAVA'
package com.luoshui.yunzhuan;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebSettings;
import android.view.WindowManager;
import android.os.Build;
import android.view.View;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WebView wv = new WebView(this);
        setContentView(wv);

        WebSettings ws = wv.getSettings();
        ws.setJavaScriptEnabled(true);
        ws.setDomStorageEnabled(true);
        ws.setAllowFileAccess(true);
        ws.setAllowContentAccess(true);
        ws.setAllowFileAccessFromFileURLs(true);
        ws.setAllowUniversalAccessFromFileURLs(true);
        ws.setLoadWithOverviewMode(true);
        ws.setUseWideViewPort(true);
        ws.setSupportZoom(false);
        ws.setBuiltInZoomControls(false);
        ws.setDisplayZoomControls(false);
        ws.setMediaPlaybackRequiresUserGesture(false);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            wv.setLayerType(View.LAYER_TYPE_HARDWARE, null);
            WebView.setWebContentsDebuggingEnabled(false);
        }

        wv.setWebViewClient(new WebViewClient());
        wv.loadUrl("file:///android_asset/public/index.html");
    }
}
JAVA

echo "=== 1. aapt2 compile ==="
mkdir -p $TMP/compiled
aapt2 compile -o $TMP/compiled $TMP/res/values/strings.xml 2>&1
FLAT_FILES=$(ls $TMP/compiled/*.flat 2>/dev/null)
echo "  Compiled: $FLAT_FILES"

echo "=== 2. aapt2 link ==="
aapt2 link -o $TMP/base.apk -I $PLAT/android.jar \
  --manifest $TMP/AndroidManifest.xml \
  -A $TMP/assets \
  --auto-add-overlay \
  $TMP/compiled/*.flat 2>&1

echo "=== 3. javac ==="
javac -d $TMP/obj -cp $PLAT/android.jar -source 11 -target 11 \
  $TMP/java/com/luoshui/yunzhuan/MainActivity.java 2>&1

echo "=== 4. d8 ==="
d8 --lib $PLAT/android.jar --output $TMP \
  $(find $TMP/obj -name "*.class") 2>&1

echo "=== 5. Add dex ==="
# Use jar (from JDK) to add classes.dex to APK
jar uf $TMP/base.apk -C $TMP classes.dex 2>&1

echo "=== 6. zipalign ==="
zipalign -p 4 $TMP/base.apk $TMP/aligned.apk 2>&1

echo "=== 7. Sign ==="
KS=$WORK/debug.keystore
[ ! -f $KS ] && keytool -genkey -v -keystore $KS -alias debug \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass android -keypass android \
  -dname "CN=YunZhuan,O=LUOSHUI,C=CN" 2>&1

apksigner sign --ks $KS --ks-pass pass:android \
  --out $WORK/yunzhuan.apk $TMP/aligned.apk 2>&1

echo ""
echo "=== ✅ DONE ==="
ls -lh $WORK/yunzhuan.apk
echo "APK: $WORK/yunzhuan.apk"
