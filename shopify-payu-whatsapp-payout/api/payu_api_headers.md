# PayU API Authorization Headers Guide

## Required Headers for Every Request

```
Content-Type: application/json
Authorization: Bearer YOUR_PAYU_JWT_TOKEN
```

## How to Get Your JWT Token

1. Log into [PayU Payouts Dashboard](https://payouts.payumoney.com)
2. Go to **Settings > API Keys**
3. Copy the **Payout JWT Token**

> ⚠️ Note: This token may expire periodically. If you receive `401 Unauthorized` errors,
> regenerate the token from the PayU dashboard and update it in Shopify Flow.

## Where to Enter Headers in Shopify Flow

In your Shopify Flow "Send HTTP request" action card:

1. Click **+ Add header**
2. Add header 1:
   - Key: `Content-Type`
   - Value: `application/json`
3. Add header 2:
   - Key: `Authorization`
   - Value: `Bearer YOUR_PAYU_JWT_TOKEN` (paste your actual token after "Bearer ")

## Important: Payouts Merchant ID (pid)

Your Payouts `pid` (Payout Merchant ID) is different from your standard PayU payment
gateway Merchant Key. The `pid` is used internally by PayU to route requests to your
Payouts account and is embedded in your JWT token automatically.

You do NOT need to send the `pid` as a separate field in the request body.

## Test vs Production Credentials

| Environment | Base URL | Token |
|---|---|---|
| UAT (Sandbox) | `https://uatoneapi.payu.in` | UAT JWT token from PayU |
| Production | `https://payouts.payumoney.com` | Live JWT token from PayU |

Always start with UAT credentials. Switch to production only after end-to-end testing passes.
