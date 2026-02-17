# App Icon Setup

## To change the app icon:

1. **Create your icon image:**
   - Size: 1024x1024 pixels (square)
   - Format: PNG with transparent background
   - Name it: `app_icon.png`
   - Place it in: `assets/icon/app_icon.png`

2. **Generate icons:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. **Rebuild the app:**
   ```bash
   flutter clean
   flutter build apk --release
   ```

## Note:
- The icon should be square (1024x1024 recommended)
- Use PNG format with transparent background
- The adaptive_icon_background color is set to dark (#1E1E1E)



