# Play Store graphic assets

Upload targets for the Play Console **Main store listing** page. Copy for the listing lives in
[`docs/PLAY_STORE_LISTING.md`](../../docs/PLAY_STORE_LISTING.md).

```
icon_512.png                      512x512    store listing icon
feature_graphic_1024x500.png     1024x500    banner
screenshots/phone/01-08*.png     1080x2400   the 8 phone screenshots, in upload order
screenshots/extras/              1080x2400   settings + parental gate, swap-ins
```

All files are 24-bit PNG with no alpha channel, as Play requires.

Regenerate the icon and banner with:

```sh
python3 tool/generate_store_assets.py
```

Screenshots were captured from the app running on a Pixel 8a emulator. To retake them, launch the
emulator, `flutter build apk --debug`, install, and capture with `adb exec-out screencap -p > out.png`,
then flatten the alpha channel before uploading.
