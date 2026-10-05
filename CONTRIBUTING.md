# Contributing to flutter_fincra_checkout

Thanks for your interest in improving this SDK! This is a community project. It is not affiliated with, endorsed by, or supported by Fincra.

By participating, you agree to follow our [Code of Conduct](./CODE_OF_CONDUCT.md). To report a security issue, **do not open a public issue**. Follow [SECURITY.md](./SECURITY.md) instead.

## Prerequisites

- Flutter **3.32.0** or newer (Dart **3.8.1** or newer), as required by `pubspec.yaml`.
- For running the example app: Xcode (iOS) and/or Android Studio with an emulator or device.
- A Fincra sandbox account, if you want to test against the real sandbox.

## Setup

```bash
git clone https://github.com/gaiyadev/flutter_fincra_checkout.git
cd flutter_fincra_checkout
flutter pub get
```

## Checks

CI runs these on every push and pull request. Run them before opening a PR:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Running the example app

The example app reads keys from `--dart-define` values, so nothing secret lives in source.

1. Create `example/.env.json`. It is gitignored, so never force-add it:

   ```json
   {
     "FINCRA_PUBLIC_KEY": "pk_test_...",
     "FINCRA_CHECKOUT_URL": "https://sandbox-checkout.fincra.com/pay/fcr-p-...",
     "FINCRA_REDIRECT_URL": "https://example.com/fincra-callback"
   }
   ```

2. Create the hosted checkout link **server-side** (or from your terminal). It uses your **secret** key, which must never go into the app:

   ```bash
   curl -X POST https://sandboxapi.fincra.com/checkout/payments \
     -H "api-key: $FINCRA_SECRET_KEY" \
     -H "x-pub-key: $FINCRA_PUBLIC_KEY" \
     -H "content-type: application/json" \
     -d '{"amount":500,"currency":"NGN","customer":{"name":"Test","email":"test@example.com"},"redirectUrl":"https://example.com/fincra-callback"}'
   ```

   Put `data.link` from the response into `FINCRA_CHECKOUT_URL`. Links can expire, so create a fresh one for each session.

3. Run it:

   ```bash
   cd example
   flutter run --dart-define-from-file=.env.json
   ```

## Project layout

```
lib/
├── flutter_fincra_checkout.dart        # Public API: everything exported here is public
└── src/
    ├── checkout/fincra_checkout.dart    # FincraCheckout.openWebView / openInline entry points
    ├── webview/checkout_webview.dart    # Hosted-checkout WebView, redirect interception
    ├── inline/inline_checkout.dart      # Inline checkout widget + generated HTML page
    ├── inline/javascript_bridge.dart    # Parses JS -> Flutter messages (FincraBridge channel)
    ├── models/                          # Configs, results, response and error models
    └── utils/url_handler.dart           # Completion-URL detection and status parsing
test/                                    # Unit tests (run by CI)
example/                                 # Example app
example/integration_test/                # End-to-end tests against the Fincra sandbox
```

## Testing

- **Every bug fix needs a regression test** that fails without the fix.
- **URL handling** (`UrlHandler`): unit-test it directly with plain URL strings. See `test/url_handler_test.dart`.
- **JS bridge** (`FincraBridgeMessage`): unit-test the parsing by feeding JSON strings to `FincraBridgeMessage.fromJsonString`. See `test/javascript_bridge_test.dart`.
- **Inline checkout page**: `buildInlineCheckoutHtml` is a pure function marked `@visibleForTesting`. Assert on the generated HTML/JS options (see `test/inline_checkout_html_test.dart`) instead of loading a WebView.
- **WebView widgets**: `webview_flutter` needs a real platform view, so widget behaviour (navigation, back button, errors) can't be exercised in `flutter test`. Cover it with the sandbox integration tests on a simulator or device:

  ```bash
  cd example
  flutter test integration_test --dart-define-from-file=.env.json
  ```

  These need network access and a fresh `FINCRA_CHECKOUT_URL`, so they don't run in CI.

## Public API and versioning

- Anything exported from `lib/flutter_fincra_checkout.dart` is public API. Keep internals in `lib/src/` and out of the exports, or use `show` to limit them.
- Follow [Semantic Versioning](https://semver.org/). Breaking changes to the public API need a major version bump. While the package is `0.x`, they need a minor bump, and must be called out in the CHANGELOG.
- Prefer deprecating (`@Deprecated`) over removing, and keep deprecated APIs working for at least one minor release.

## Security rules

- **Never commit keys, checkout links, or `.env` files.** `.env`, `.env.*` and `*.env.json` are gitignored. Keep it that way.
- Only the **public** key (`pk_...`) may ever be in app code. The **secret** key stays on a server or in your local shell.
- Don't paste real keys, customer data, or live checkout links into issues, PRs or logs.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `fix:` a bug fix
- `feat:` a new feature
- `docs:` documentation only
- `test:` adding or fixing tests
- `chore:` maintenance (deps, tooling)
- `ci:` CI configuration

Example: `fix: treat payment_status=failed as an error`

## Pull requests

- Keep each PR to **one topic**. Unrelated fixes go in separate PRs.
- Branch from `main` and open the PR against `development`.
- Add an entry under `## [Unreleased]` in [CHANGELOG.md](./CHANGELOG.md).
- Update the README if you change public API or behaviour.
- Make sure all checks pass and fill in the PR template.

## Releasing (maintainers)

1. Bump `version` in `pubspec.yaml`.
2. In `CHANGELOG.md`, rename `## [Unreleased]` to the new version and start a fresh `## [Unreleased]` section.
3. Check the package:

   ```bash
   dart pub publish --dry-run
   ```

4. Commit, then tag and push:

   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

5. Publish:

   ```bash
   dart pub publish
   ```

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](./LICENSE).
