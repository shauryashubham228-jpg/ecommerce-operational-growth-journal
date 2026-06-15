# Shopify Flow — Configuration Reference Guide

This document describes exactly how to configure the Shopify Flow workflow manually,
step by step, within the Shopify Admin interface.

---

## Workflow Overview

```
TRIGGER
  └── Admin Button Clicked: "Send PayU COD Payout Link"
        │
        ▼
STEP 1: Send HTTP Request → PayU Smart Send API
  │     (generates OTP-locked payout link)
  │     Output: {{http.response.body.data.payoutLink}}
  │
  ▼
STEP 2: Send HTTP Request → Interakt WhatsApp API
  │     (sends WhatsApp template to customer)
  │
  ▼
STEP 3: Add Order Comment → Shopify Timeline
        (logs link + status for internal audit trail)
```

---

## Trigger Configuration

| Setting | Value |
|---|---|
| App | Admin Buttons (or your installed admin extension app) |
| Event | Admin Button Clicked |
| Button | Send PayU COD Payout Link |

---

## Step 1: PayU Smart Send HTTP Request

| Field | Value |
|---|---|
| Action Type | Send HTTP request |
| HTTP Method | POST |
| URL (UAT) | `https://uatoneapi.payu.in/payout/v2/smartSend/link` |
| URL (Prod) | `https://payouts.payumoney.com/payout/v2/smartSend/link` |

**Headers:**

| Key | Value |
|---|---|
| `Content-Type` | `application/json` |
| `Authorization` | `Bearer YOUR_PAYU_JWT_TOKEN` |

**Request Body:**

```json
{
  "amount": "{{order.totalPriceSet.shopMoney.amount}}",
  "merchantRefId": "SHOPIFY_COD_{{order.name}}",
  "custName": "{{order.customer.firstName}} {{order.customer.lastName}}",
  "custMobile": "{{order.customer.phone}}",
  "description": "COD Dispute Refund for Order {{order.name}}",
  "expiryDate": "2026-07-01T23:59:59Z"
}
```

> 🔁 Update `expiryDate` periodically (at least monthly) or use the utility script
> in `scripts/generate_expiry_timestamp.js` to generate a fresh timestamp.

**Key Output Variable (used in Steps 2 and 3):**
```
{{http.response.body.data.payoutLink}}
```

---

## Step 2: Interakt WhatsApp HTTP Request

| Field | Value |
|---|---|
| Action Type | Send HTTP request |
| HTTP Method | POST |
| URL | `https://api.interakt.ai/v1/public/message/` |

**Headers:**

| Key | Value |
|---|---|
| `Content-Type` | `application/json` |
| `Authorization` | `Basic YOUR_INTERAKT_API_KEY` |

**Request Body:**

```json
{
  "countryCode": "+91",
  "phoneNumber": "{{order.customer.phone}}",
  "callbackData": "Shopify_COD_Refund_{{order.name}}",
  "template": {
    "name": "cod_dispute_payout_link",
    "languageCode": "en",
    "bodyValues": [
      "{{order.customer.firstName}}",
      "{{order.totalPriceSet.shopMoney.amount}}",
      "{{order.name}}"
    ],
    "buttonValues": {
      "0": [
        "{{http.response.body.data.payoutLink}}"
      ]
    }
  }
}
```

> 🔑 Replace `cod_dispute_payout_link` with the exact template code name from your
> Interakt Template Manager.

---

## Step 3: Shopify Order Timeline Comment

| Field | Value |
|---|---|
| Action Type | Add order comment (Shopify native) |
| Order | Current order from trigger context |

**Comment Text:**

```
📩 PayU COD Payout Link Generated.
• Amount Locked: ₹{{order.totalPriceSet.shopMoney.amount}}
• Customer Mobile: {{order.customer.phone}}
• Order Reference: {{order.name}}
• Status: Dispatched automatically via WhatsApp (Interakt).
• Reference Link: {{http.response.body.data.payoutLink}}
• Initiated by: Support Agent (automated trigger)
```

---

## Important Shopify Variable Reference

| Shopify Flow Variable | What It Returns |
|---|---|
| `{{order.name}}` | Order ID like `#1042` |
| `{{order.totalPriceSet.shopMoney.amount}}` | Total order value (works for COD — bypasses "unpaid" status) |
| `{{order.customer.firstName}}` | Customer first name |
| `{{order.customer.lastName}}` | Customer last name |
| `{{order.customer.phone}}` | Customer phone number |
| `{{order.billingAddress.phone}}` | Fallback phone (use if customer.phone is empty) |
| `{{http.response.body.data.payoutLink}}` | The PayU payout link returned from Step 1 |

---

## Saving and Activating

1. Click **Save** after configuring all 3 steps
2. Toggle the workflow status from **Inactive** to **Active**
3. The button in Shopify's "More actions" menu will now be fully functional
