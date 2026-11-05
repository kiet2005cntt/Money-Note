#!/usr/bin/env bash
# =============================================================================
# MoneyScan — Script dựng project
# Chạy ngày 24/10/2026, bạn A thực hiện
#
# Cách chạy:
#   Windows : mở Git Bash, gõ   bash setup_project.sh
#   macOS   : chmod +x setup_project.sh && ./setup_project.sh
#
# Script này tạo project Flutter, dựng cấu trúc Clean Architecture
# và cài toàn bộ dependency cần cho đồ án.
# =============================================================================

set -e  # dừng ngay khi có lệnh lỗi

PROJECT_NAME="moneyscan"
ORG="com.hcmute"   # đổi thành mã trường/nhóm của bạn

echo ""
echo "=========================================="
echo "  MoneyScan — Dựng project"
echo "=========================================="
echo ""

# --- Kiểm tra Flutter ------------------------------------------------------
if ! command -v flutter &> /dev/null; then
  echo "LỖI: không tìm thấy lệnh flutter."
  echo "Kiểm tra lại biến môi trường PATH, xem mục 1 trong GIAI_DOAN_0_SETUP.md"
  exit 1
fi

echo "Phiên bản Flutter đang dùng:"
flutter --version | head -n 1
echo ""

# --- Tạo project -----------------------------------------------------------
if [ -d "$PROJECT_NAME" ]; then
  echo "Thư mục $PROJECT_NAME đã tồn tại, bỏ qua bước tạo project."
else
  echo "[1/5] Tạo project Flutter..."
  flutter create \
    --org "$ORG" \
    --project-name "$PROJECT_NAME" \
    --platforms android \
    "$PROJECT_NAME"
fi

cd "$PROJECT_NAME"

# --- Cấu trúc thư mục Clean Architecture -----------------------------------
echo "[2/5] Dựng cấu trúc thư mục..."

mkdir -p lib/core/{theme,constants,utils,error,di}
mkdir -p lib/data/{models,datasources/local,datasources/remote,repositories}
mkdir -p lib/domain/{entities,repositories,usecases}
mkdir -p lib/presentation/{screens,widgets,providers,router}
mkdir -p lib/presentation/screens/{splash,auth,home,transaction,wallet,category,report,budget,ocr,settings}
mkdir -p test/{domain,data,presentation}
mkdir -p assets/images
mkdir -p docs

# Giữ thư mục rỗng trong git
find lib test assets docs -type d -empty -exec touch {}/.gitkeep \;

# --- Cài dependency --------------------------------------------------------
# Dùng `flutter pub add` thay vì ghi cứng version vào pubspec,
# để luôn lấy bản mới nhất tương thích.
echo "[3/5] Cài dependency (mất vài phút)..."

# State management
flutter pub add flutter_riverpod

# Database local
flutter pub add drift
flutter pub add sqlite3_flutter_libs
flutter pub add path_provider
flutter pub add path

# Firebase
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore

# Điều hướng
flutter pub add go_router

# Camera + OCR
flutter pub add image_picker
flutter pub add google_mlkit_text_recognition
flutter pub add permission_handler

# Biểu đồ
flutter pub add fl_chart

# Thông báo
flutter pub add flutter_local_notifications
flutter pub add timezone

# Tiện ích
flutter pub add uuid
flutter pub add intl
flutter pub add share_plus
flutter pub add csv
flutter pub add connectivity_plus
flutter pub add equatable

# Dev dependency
flutter pub add --dev build_runner
flutter pub add --dev drift_dev
flutter pub add --dev mocktail

# --- Cấu hình Android ------------------------------------------------------
echo "[4/5] Cấu hình Android..."

GRADLE_FILE="android/app/build.gradle"
if [ -f "android/app/build.gradle.kts" ]; then
  GRADLE_FILE="android/app/build.gradle.kts"
fi

echo ""
echo "  >> CẦN SỬA TAY trong $GRADLE_FILE:"
echo "     - minSdk = 23        (ML Kit và Firebase yêu cầu)"
echo "     - ndkVersion         (nếu build báo lỗi NDK, dùng version nó gợi ý)"
echo ""
echo "  >> CẦN THÊM TAY vào android/app/src/main/AndroidManifest.xml,"
echo "     đặt bên trong thẻ <manifest>, phía trên <application>:"
echo ""
cat <<'MANIFEST'
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
MANIFEST
echo ""

# --- .gitignore bổ sung ----------------------------------------------------
echo "[5/5] Bổ sung .gitignore..."
cat >> .gitignore <<'GITIGNORE'

# ---- MoneyScan ----
# Khóa Firebase, KHÔNG push lên repo công khai
android/app/google-services.json
lib/firebase_options.dart
ios/Runner/GoogleService-Info.plist

# File sinh tự động bởi build_runner
*.g.dart
*.freezed.dart

# File build
*.apk
*.aab
GITIGNORE

# --- Xong ------------------------------------------------------------------
echo ""
echo "=========================================="
echo "  XONG"
echo "=========================================="
echo ""
echo "Cấu trúc đã tạo:"
echo ""
echo "  lib/"
echo "  ├── core/          theme, constants, utils, error, di"
echo "  ├── data/          models, datasources, repositories"
echo "  ├── domain/        entities, repositories, usecases"
echo "  └── presentation/  screens, widgets, providers, router"
echo ""
echo "Việc tiếp theo:"
echo ""
echo "  1. Chép entities.dart và repositories.dart vào lib/domain/"
echo "  2. Sửa minSdk = 23 trong $GRADLE_FILE"
echo "  3. Thêm 4 dòng quyền vào AndroidManifest.xml (xem phía trên)"
echo "  4. Chạy Firebase:  flutterfire configure"
echo "  5. Kiểm tra:       flutter run"
echo ""
echo "LƯU Ý: .gitignore đang chặn firebase_options.dart."
echo "Repo là Private nên 2 bạn cần chia sẻ file này cho nhau thủ công"
echo "(gửi qua Zalo/Drive), hoặc mỗi người tự chạy flutterfire configure."
echo ""
