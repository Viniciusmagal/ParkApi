set -e
export PATH="$HOME/flutter/bin:$PATH"
cd park_app
flutter pub get
flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:8080}"
