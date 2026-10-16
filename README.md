# Accounting Bag | الحقيبة المحاسبية

A bilingual, offline-first Flutter Android accounting toolkit.

## MVP implemented
- Arabic and English UI with RTL support.
- 4 working calculators: straight-line depreciation, markup on cost, break-even units, quick ratio.
- 4 quiz questions with scoring.
- 5 accounting summaries.
- 5 double-entry journal examples.
- 3 read-only accounting templates.

No WebView, login, network permissions or ad SDK required for this MVP.

## Build
Install Flutter (Dart >=3.3), then run:
```bash
flutter create . --platforms=android --org com.explapp
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```
The scaffold step creates missing Android platform folders in this starter repository.

## Roadmap
1. Add fully editable templates with local storage and proper Excel/PDF export.
2. Add a content library, search and study progress persistence.
3. Add further validated calculators and bilingual quizzes with explanations.
4. Test on actual Android devices before releasing APK/AAB.

Accounting outputs are educational and require verification for professional use.
