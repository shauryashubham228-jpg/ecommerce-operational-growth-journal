# 📋 Setup Guide — Shopify × PayU × Interakt Payout Integration

Follow each phase in order. Estimated total setup time: **5–6 hours across 5 days** (most steps are waiting for approvals).

---

## Phase 1: PayU Account Preparation
**Estimated Time: Day 1 (30 minutes action + 1–2 days for PayU to activate)**

### 1.1 — Activate Smart Send (Payout Links)

Log into your [PayU Payouts Dashboard](https://payouts.payumoney.com) and raise a support ticket or contact your PayU Account Manager with this message:

```
Subject: Activate Smart Send, Penny Drop & Name Matching — Payouts Account

Hi Team,

Please activate the following features on our Payouts account:
1. Smart Send (Payout Links) — to generate OTP-secured refund links
2. Penny Drop Verification — for account validation before transfer
3. Automated Beneficiary Name Matching (70% fuzzy match threshold)

Our Merchant ID: [YOUR_MERCHANT_ID]

Thank you.
```

### 1.2 — Collect Your Payouts API Credentials

Once activated, collect these three values from your PayU Payouts Dashboard under **Settings > API Keys**:

| Credential | Where to Find It | Variable Name in This Repo |
|---|---|---|
| Payout Merchant Key | Dashboard > Settings > API Keys | `YOUR_PAYU_MERCHANT_KEY` |
| Payout Salt | Dashboard > Settings > API Keys | `YOUR_PAYU_SALT` |
| Payout JWT Token | Dashboard > Settings > API Keys | `YOUR_PAYU_JWT_TOKEN` |

> ⚠️ **Note:** Your Payouts Merchant Key (`pid`) is **different** from your regular PayU payment gateway Merchant Key. Do not mix them up.

### 1.3 — Fund Your Payout Wallet

Add a float balance to your PayU Payout virtual wallet via RTGS or NEFT so refund transfers have funds to draw from:

- **Account Name:** PayU Payments Private Limited
- **Account Type:** Current Account
- **Bank Details:** Provided in your PayU Payouts Dashboard under **Add Funds**

---

## Phase 2: Shopify Admin Button Setup
**Estimated Time: Day 2 (1–2 hours)**

### 2.1 — Install the Admin Buttons App

1. Go to the [Shopify App Store](https://apps.shopify.com)
2. Search for **"Admin Buttons"** (by Even Better Apps) or a compatible admin extension app
3. Install and open the app

### 2.2 — Create the Custom Order Button

Inside the Admin Buttons app:

| Setting | Value |
|---|---|
| Button Label | `Send PayU COD Payout Link` |
| Button Location | `Order Details Page` |
| Placement | `More Actions dropdown` |
| Action | `Trigger Shopify Flow Workflow` |

3. Save the button

### 2.3 — Verify Button Appears

Open any order in your Shopify Admin and click the **"More actions"** dropdown at the top right of the order page. You should see **"Send PayU COD Payout Link"** listed.

---

## Phase 3: WhatsApp Template Setup via Interakt
**Estimated Time: Day 3 (30 minutes action + 24–48 hours for Meta approval)**

### 3.1 — Log Into Interakt

Access your [Interakt Dashboard](https://app.interakt.ai) and navigate to **Templates > Create Template**.

### 3.2 — Submit This Template for Meta Approval

Use these exact values when creating the template:

| Field | Value |
|---|---|
| Template Name | `cod_dispute_payout_link` |
| Category | `UTILITY` |
| Language | `English` |

**Template Body Text:**
```
Hi {{1}}, your COD dispute refund of ₹{{2}} for Order {{3}} is ready.

Click the secure button below to enter your UPI ID or bank details and receive your instant transfer.

This link expires in 48 hours.
```

**Button Configuration:**
| Setting | Value |
|---|---|
| Button Type | `Call to Action` |
| Action Type | `Visit Website` |
| Button Label | `Claim Your Refund` |
| URL Type | `Dynamic` |
| URL | `https://payu.in/{{1}}` |

> ⚠️ The button URL uses a dynamic suffix placeholder. Your actual PayU link will be injected here at runtime by Shopify Flow.

### 3.3 — Note Your Template Code Name

Once Meta approves the template (24–48 hours), note the **exact system template name** shown in Interakt's Template Manager. You will need this in Phase 4.

### 3.4 — Get Your Interakt API Key

In Interakt, go to **Settings > Developer Settings** and copy your **API Key**. This is used in the `Authorization: Basic YOUR_INTERAKT_API_KEY` header.

---

## Phase 4: Shopify Flow Automation Chain
**Estimated Time: Day 4–5 (2–3 hours)**

This is the core of the integration. You will build a 3-step sequential automation in Shopify Flow.

### 4.1 — Open Shopify Flow

In your Shopify Admin, go to **Apps > Shopify Flow > Create workflow**.

### 4.2 — Set the Trigger

- Click **Select a trigger**
- Choose **Admin Button Clicked** (from the Admin Buttons app)
- Select the button you created: **"Send PayU COD Payout Link"**

---

### 4.3 — Add Step 1: Call PayU Smart Send API

Click **"Then" (+)** and add an action: **"Send HTTP request"**

Configure as follows:

**HTTP Method:** `POST`

**URL:**
```
# For UAT/Testing:
https://uatoneapi.payu.in/payout/v2/smartSend/link

# For Production (switch after testing):
https://payouts.payumoney.com/payout/v2/smartSend/link
```

**Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer YOUR_PAYU_JWT_TOKEN"
}
```

**Request Body (JSON):**
```json
{
  "amount": "{{order.totalPriceSet.shopMoney.amount}}",
  "merchantRefId": "SHOPIFY_COD_{{order.name}}",
  "custName": "{{order.customer.firstName}} {{order.customer.lastName}}",
  "custMobile": "{{order.customer.phone}}",
  "description": "COD Dispute Refund for Order {{order.name}}",
  "expiryDate": "{{scripts/generate_expiry_timestamp.js output}}"
}
```

> 💡 **Why `totalPriceSet` and not `amountPaid`?** COD orders are "Pending/Unpaid" in Shopify because cash hasn't been processed digitally. Using `totalPriceSet.shopMoney.amount` reads the total value of goods, bypassing the zero-paid balance issue.

**Expected PayU Success Response:**
```json
{
  "status": "success",
  "msg": "Link created successfully",
  "data": {
    "payoutLink": "https://payu.in/s/XXXXX"
  }
}
```

The variable `{{http.response.body.data.payoutLink}}` now holds the unique OTP-locked link. This is passed to the next step.

---

### 4.4 — Add Step 2: Send WhatsApp Message via Interakt

Click **"Then" (+)** and add another action: **"Send HTTP request"**

**HTTP Method:** `POST`

**URL:**
```
https://api.interakt.ai/v1/public/message/
```

**Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Basic YOUR_INTERAKT_API_KEY"
}
```

**Request Body (JSON):**
```json
{
  "countryCode": "+91",
  "phoneNumber": "{{order.customer.phone}}",
  "callbackData": "Shopify_COD_Refund_{{order.name}}",
  "template": {
    "name": "YOUR_APPROVED_TEMPLATE_CODE_NAME",
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

> 🔑 Replace `YOUR_APPROVED_TEMPLATE_CODE_NAME` with the exact template name string from Interakt's Template Manager (e.g., `cod_dispute_payout_link`).

---

### 4.5 — Add Step 3: Log Shopify Order Timeline Comment

Click **"Then" (+)** and add a final action: **"Add order comment"** (Shopify native action)

**Comment Body:**
```
📩 PayU COD Payout Link Generated.
• Amount Locked: ₹{{order.totalPriceSet.shopMoney.amount}}
• Customer Mobile: {{order.customer.phone}}
• Order Reference: {{order.name}}
• Status: Dispatched automatically via WhatsApp (Interakt).
• Reference Link: {{http.response.body.data.payoutLink}}
• Initiated by: Support Agent (automated trigger)
```

### 4.6 — Save and Enable the Workflow

Click **Save** and toggle the workflow to **Active**.

---

## Phase 5: Testing
**Estimated Time: Day 6 (1–2 hours)**

See [`docs/TROUBLESHOOTING.md`](TROUBLESHOOTING.md) for a full testing checklist and error code reference.

### Quick Test Steps

1. Go to **Shopify Admin > Orders > Create order**
2. Add any test product (e.g., ₹100)
3. Add **your own name and mobile number** as the customer
4. Select **Cash on Delivery** as payment method
5. Save the order
6. Open the order → Click **"More actions" > "Send PayU COD Payout Link"**
7. Check your WhatsApp for the template message
8. Check the order Timeline for the automated comment
9. Tap the link → verify OTP flow works → confirm UPI entry screen loads

### Switching to Production

Once all three steps show **green** in the Shopify Flow Activity Log:

1. Open your Shopify Flow workflow
2. In the PayU HTTP request card, change the URL from:
   ```
   https://uatoneapi.payu.in/payout/v2/smartSend/link
   ```
   to:
   ```
   https://payouts.payumoney.com/payout/v2/smartSend/link
   ```
3. Replace the test JWT token with your **live PayU JWT token**
4. Save and you are live ✅

---

## ✅ Setup Complete Checklist

- [ ] PayU Smart Send activated by account manager
- [ ] PayU Payout wallet funded
- [ ] PayU API credentials (Key, Salt, JWT) collected
- [ ] Admin Buttons app installed + button created on Order Details page
- [ ] Interakt WhatsApp template submitted and Meta-approved
- [ ] Interakt API Key collected
- [ ] Shopify Flow workflow created with 3 steps (PayU → Interakt → Timeline)
- [ ] Test order created and full flow validated in UAT
- [ ] Switched to production URLs and live tokens
- [ ] Support team briefed using Agent SOP (`docs/AGENT_SOP.md`)
