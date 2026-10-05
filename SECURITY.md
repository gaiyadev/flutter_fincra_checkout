# Security Policy

`flutter_fincra_checkout` is a community project. It is not affiliated with, endorsed by, or supported by Fincra.

## Supported versions

| Version | Supported |
| :--- | :--- |
| 0.1.x | ✅ |
| < 0.1 | ❌ |

Security fixes are released as a new patch version of the latest supported series. Please upgrade to the latest release before reporting.

## Reporting a vulnerability

**Do not open a public issue, pull request or discussion for security problems.**

Report privately with GitHub's Private Vulnerability Reporting:

1. Go to the repository's **Security** tab.
2. Click **Report a vulnerability** ([direct link](https://github.com/gaiyadev/flutter_fincra_checkout/security/advisories/new)).
3. Include:
   - the SDK version (from `pubspec.lock`);
   - the platform (iOS/Android, OS version, device or simulator);
   - the checkout mode (**WebView** or **Inline**);
   - the impact: what an attacker can do, and under what conditions;
   - a minimal reproduction (code and steps).

**Never include real API keys, live checkout links, or customer data in a report.** Use sandbox values or redact them.

## What to expect

- We aim to acknowledge reports **within 7 days**. This is a volunteer-maintained project, so this is best effort.
- We'll keep you updated while we investigate and work on a fix.
- Once a fix is released, we publish a GitHub Security Advisory. **You'll be credited** in it unless you'd rather stay anonymous.

## Scope

**In scope:** this SDK's code, for example:

- spoofing a payment result or redirect, e.g. a URL that the SDK wrongly treats as a completed payment;
- injecting script or markup into the generated inline checkout page through config values;
- the SDK reporting the wrong payment outcome (success for a failed payment, or the reverse);
- the SDK leaking keys, references or customer data (logs, URLs, storage).

**Out of scope:**

- the Fincra platform, API, hosted checkout page or JS SDK. Report those to Fincra directly;
- vulnerabilities in dependencies (e.g. `webview_flutter`) with no demonstrated impact on this SDK. Report those upstream;
- issues that require a compromised device or a modified app;
- missing best practices with no concrete exploit.

## Guidance for integrators

- **Keep your secret key on your server.** Only the public key (`pk_...`) belongs in the app.
- **Verify every payment on your server** with the Fincra API or a webhook before fulfilling an order. The SDK's result is a UX signal, not proof of payment.
- **Always set `redirectUrl`** for WebView checkout, and use the same value your backend sent to Fincra.
- **Keep the SDK up to date** to get security fixes.
