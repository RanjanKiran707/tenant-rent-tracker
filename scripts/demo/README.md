# Demo video scripts

Drive the Rent Book app on a real Android phone over adb, record each step, and join the takes into a
captioned `docs/demo.mp4`. The scripts find buttons by their on-screen text, so they don't depend on
screen coordinates.

The flow recorded: Welcome guide, add a group, add a tenant, record a part payment, then the rest,
and finish on the Home totals.

## What you need

- Python 3 (no packages to install)
- `adb` and `scrcpy` (2.x), with the phone connected over USB and USB debugging on
- `ffmpeg` built with the `drawtext` filter (captions). Some builds, such as Shotcut's, don't have it.
  Check with `ffmpeg -filters | grep drawtext`
- Keep the phone unlocked with the screen on while recording

## 1. Build a separate demo app

The script reinstalls the demo app to start from empty data, so it must not be your real app. Give the
debug build its own id by adding this to `buildTypes` in `android/app/build.gradle.kts` (don't commit it):

```kotlin
debug {
    applicationIdSuffix = ".demo"
}
```

Then build it:

```bash
flutter build apk --debug
```

The demo app is `com.ranjankiran.rentbook.demo`. It installs next to the real Rent Book and doesn't
touch its data.

## 2. Record

From this folder. On Windows, set the full paths if the tools aren't on PATH:

```bash
export ADB="C:\Users\<you>\AppData\Local\Android\Sdk\platform-tools\adb.exe"
export SCRCPY="C:\path\to\scrcpy-win64-v2.5\scrcpy.exe"

python record_demo.py all        # reinstall the demo app, then record takes 1-4
```

Takes are saved in `out/take1.mkv` ... `out/take4.mkv`. To redo one take, run `python record_demo.py reset`
to start from empty data again, then run the takes up to that one without recording
(`python record_demo.py 1 norec`) and record the one you want (`python record_demo.py 3`).

| Command | What it does |
|---|---|
| `python record_demo.py reset` | Uninstall and reinstall the demo app (empty data) and open it |
| `python record_demo.py N` | Record take N (1-4) |
| `python record_demo.py N norec` | Run take N without recording, to rehearse |
| `python record_demo.py all` | `reset`, then every take in order |

If a step can't find a button, the script saves `out/fail_takeN.png`, prints everything on screen and
exits.

## 3. Make the video

```bash
export FFMPEG="C:\path\to\ffmpeg.exe"
python make_video.py             # writes ../../docs/demo.mp4
python make_video.py my.mp4      # or choose the output file
```

This trims each take, speeds it up 1.25x, adds a caption (edit `CAPTIONS` in `make_video.py`) and
compresses to a small MP4. Check the size: GitHub plays a README video inline only if it is small
(under about 10 MB when committed to the repo).

## Settings

| Env var | Default | Purpose |
|---|---|---|
| `ADB` | `adb` | Path to adb |
| `SCRCPY` | `scrcpy` | Path to scrcpy |
| `FFMPEG` | `ffmpeg` | Path to ffmpeg |
| `DEMO_PKG` | `com.ranjankiran.rentbook.demo` | App id of the demo build |
| `DEMO_APK` | `build/app/outputs/flutter-apk/app-debug.apk` | APK reinstalled by `reset` |
| `DEMO_OUT` | `scripts/demo/out` | Where takes are saved |
| `CAPTION_FONT` | `C:/Windows/Fonts/arialbd.ttf` | Caption font (.ttf) |

## Notes

- `adb shell screenrecord` crashes on some phones (it did on the test phone), so recording uses
  `scrcpy --record`. It works with scrcpy's mirror window already open.
- `adb shell pm clear` is blocked on some phones, so `reset` reinstalls the app instead.
- The debug build shows a small DEBUG ribbon in the corner of the video.
- To change the flow, edit the `take1` ... `take4` functions in `record_demo.py`. Helpers such as
  `tap("Save", exact=True)`, `fill(0, "text")` and `back()` are in `adb_driver.py`.
