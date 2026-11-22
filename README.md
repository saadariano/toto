# Linko Net for Android

The APK bundles the editable `index.html` in Android WebView. The launcher and web app use the same Linko Net mark. External links open in the user's browser.

## Build a release

Use a JDK, Android platform 36, Android Build Tools 36.0.0 and the existing Linko Net release keystore. Set `ANDROID_SDK_ROOT`, `LINKO_KEYSTORE` (the absolute path to the keystore), and `LINKO_KEY_PASSWORD` privately. Run `./build.sh`. For an in-place update, keep package ID `net.linkonet.app` and the same signing key, and increase `android:versionCode` and `APK_VERSION` to the same new integer. Update `android:versionName` as well.

## Publish an APK update

1. Upload the signed APK and a JSON file based on `release.example.json` to an HTTPS host you control. Set the version fields to match the APK and set `apkUrl` to its download URL or a path relative to the feed.
2. Enable CORS on the JSON response. A public, credential-free feed can send `Access-Control-Allow-Origin: *`.
3. Paste the feed URL in Linko Net under **Settings → APK update feed** and choose **Save & check APK**. For preconfigured builds, set `DEFAULT_APK_FEED` in `index.html` before rebuilding.

The app checks the feed on launch and when returning to the foreground, at most once a minute. For a higher version code, it offers to open the download in the browser. Android handles installation after download.

The FMHY bookmark feed is built in. Linko Net previews incoming additions and merges them after confirmation. Existing favorites, custom links and deleted-link preferences remain in local storage.
