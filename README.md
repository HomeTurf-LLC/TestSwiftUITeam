# TestSwiftUITeam
Test SwiftUI Team project using HomeTurf SDK

## Setup

See the [HomeTurfPodSpecs repo](https://github.com/HomeTurf-LLC/hometurfpodspecs) for project requirements and cocoapod setup instructions. The following instructions assume you have already added/updated a Podfile, run `pod install`, and opened your project with its `PROJECT_NAME.xcworkspace` file.

### Project Configuration Summary

For convenience, the list of integration steps once the SDK has been installed is:

1. Add `HomeTurf.plist` (structure below - specific values will be provided by HomeTurf)
2. Update `Info.plist` with required values below
3. Update `AppDelegate` for orientation locking support
4. Add `TeamHomeTurfOrientationUtility` file that implements our HomeTurfBaseOrientationUtility protocol
5. Update the ViewController that the app will launch from with a launch action
6. (RECOMMENDED) Add Push Notification and Background Mode capabilities

(OPTIONAL) In addition to the above, if adding Auth0:
1. Ensure that Podfile includes Auth0 dependency, and `pod install` again if needed
2. Add Auth0Service that implements our BaseAuth0Service protocol (example provided)
3. Update `HomeTurf.plist` with required Auth0 values
4. Update `Info.plist` with required Auth0 URL values
5. Update `AppDelegate` with required import and method
6. Update ContentView to use `TeamHomeTurfAuth0Service`

### Project Configuration Steps

1. Add `HomeTurf.plist`

Add a new properties file to your project called `HomeTurf.plist`, with that name and casing (and with target membership in that project). Right click the file in Xcode and select Open As -> Source Code. Enter the following (substituting the team id we provide for HOMETURF_TEAM_ID):

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>HomeTurfDomain</key>
    <string>https://app.hometurfapp.com</string>
    <key>HomeTurfTeamId</key>
    <string>HOMETURF_TEAM_ID</string>
</dict>
</plist>
```

2. Update `Info.plist`

Select your existing `Info.plist` in Xcode, Open as -> Source Code, and insert the following permissions/configuration before the last `</dict>`. Make sure to consolidate any values or skip if your project already has them.

```
    <key>NSAppleMusicUsageDescription</key>
    <string>HomeTurf would like to access your media library</string>
    <key>NSCameraUsageDescription</key>
    <string>HomeTurf would like to access your camera</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>HomeTurf would like to access your location in order to ensure compliance with local regulations</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>HomeTurf needs to access your microphone for live channel calibration and team scream.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>HomeTurf would like to access your photo library</string>
    <key>UIBackgroundModes</key>
    <array>
      <string>audio</string>
      <string>fetch</string>
    </array>
```

3. Add the following to `AppDelegate.swift` (note that the HomeTurf SDK may raise an error if the orientationLock variable is not available on the AppDelegate object):

```
    var orientationLock = UIInterfaceOrientationMask.all

    /// needs to be added to support orientation locking
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
```

4. Add a `TeamHomeTurfOrientationUtility.swift` file to your project (and target membership), which you can copy from the HomeTurfSupport directory in our demo project [here](./TestSwiftUITeam/HomeTurfSupport/TeamHomeTurfOrientationUtility.swift).

5. Add something like the following to the SwiftUI View where HomeTurf will be started from. Ultimately the `HomeTurfWebView` (as a UIViewControllerRepresentable instance) will start up the WebViewController in a navigation stack with this approach:

```
import SwiftUI
import HomeTurf

...
  NavigationView {
    ZStack {
      ...
      VStack(spacing: 30) {
        ...
        NavigationLink(destination: HomeTurfWebView(orientationUtility: TeamHomeTurfOrientationUtility.init())) {
            Text("Go to HomeTurf")
        }
      }
    ...
    }
  }
```

(Other methods such as modal presentation as possible, but using a navigation view will provide the most immersive experience.)

6. If not already, make sure the following are checked in Signing & Capabilities:

- Audio, Airplay and Picture in Picture
- Background fetch

#### (OPTIONAL) Auth0 Support

1. Make sure your Podfile includes 

```.sh
  pod 'Auth0', '~> 1.31' # Optional - only if using Auth0 for authentication
```

and `pod install` again if necessary.

2. Add a new Auth0Service file that implements the HomeTurf `BaseAuth0Service` protocol - currently with init, setJavascriptService, login, and logout methods. We have provided a sample [./support/TeamHomeTurfAuth0Service.swift](./TeamHomeTurfAuth0Service.swift) file you can copy into your project (and add to your target membership). The HomeTurf SDK will set its credentials from `HomeTurf.plist`.

3. Update `HomeTurf.plist`

Add the following new values to `HomeTurf.plist` before the last `</dict>` (domain and clientId to be provided by us, although if desired team-owned auth0 configuration can be discussed as well):

```
    <key>HomeTurfUseNativeAuth0</key>
    <true/>
    <key>HomeTurfAuth0Domain</key>
    <string>AUTH0_DOMAIN</string>
    <key>HomeTurfAuth0ClientId</key>
    <string>AUTH0_CLIENT_ID</string>
    <key>HomeTurfAuth0Audience</key>
    <string>https://api.hometurfapp.com/v1/api/</string>
```

The entire file should now look like this:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>HomeTurfDomain</key>
    <string>https://app.hometurfapp.com</string>
    <key>HomeTurfTeamId</key>
    <string>HOMETURF_TEAM_ID</string>
    <key>HomeTurfUseNativeAuth0</key>
    <true/>
    <key>HomeTurfAuth0Domain</key>
    <string>AUTH0_DOMAIN</string>
    <key>HomeTurfAuth0ClientId</key>
    <string>AUTH0_CLIENT_ID</string>
    <key>HomeTurfAuth0Audience</key>
    <string>https://api.hometurfapp.com/v1/api/</string>
</dict>
</plist>
```

4. Update `Info.plist` to include the following additional configuration (make sure you've already included the configuration in the previous section) all before the last `</dict>`, consolidating with any existing values if necessary:

```
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>None</string>
            <key>CFBundleURLName</key>
            <string>auth0</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
            </array>
        </dict>
    </array>
```

5. Update `AppDelegate.swift` to include the following (in addition to the essential orientation locking code in the previous section):

```
import Auth0

...

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
            return Auth0.resumeAuth(url)
        }
```

6. Update your launching View's launch method to include the auth0 service, i.e.:

```
...
  VStack(spacing: 30) {
    ...
    NavigationLink(destination: HomeTurfWebView.init(auth0Service: TeamHomeTurfAuth0Service.init())) {
        Text("Go to HomeTurf")
    }
  }
...
```

### Updates

Generally updates will only require an update to the Podfile HomeTurf version and a subsequent `pod install`.

### Support

Feel free to reach out to HomeTurf if you have any issues with the above steps or need any configuration information.

