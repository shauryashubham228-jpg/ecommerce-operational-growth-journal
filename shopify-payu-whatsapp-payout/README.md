# 🚀 Shopify × PayU × Interakt — Automated COD Dispute Payout System

> Send OTP-secured WhatsApp payout links to disputed COD customers directly from the Shopify Order page — no manual dashboard switching required.

---

## 📌 What This Does

When a customer disputes a **Cash on Delivery (COD)** order, your support agent clicks one button inside the Shopify Admin. The system automatically:

1. Reads the order's total value from Shopify
2. Calls PayU's **Smart Send API** to generate an OTP-secured payout link
3. Sends the link to the customer via **WhatsApp** using Interakt
4. Logs the link and status directly in the **Shopify Order Timeline**

The customer receives a WhatsApp message, clicks the link, verifies via OTP, enters their UPI ID, and receives the refund instantly — without your team ever logging into PayU's dashboard.

---

## 🗺️ Project Roadmap

```
Phase 1: PayU Setup (Day 1)
   └── Activate Smart Send + get API credentials

Phase 2: Shopify Admin Button (Day 2)
   └── Install Admin Buttons app + configure Order page button

Phase 3: Interakt WhatsApp Template (Day 3)
   └── Create + submit Meta-approved template

Phase 4: Shopify Flow Automation (Day 4–5)
   ├── Step 1 → Call PayU API → get payout link
   ├── Step 2 → Call Interakt API → send WhatsApp message
   └── Step 3 → Add Shopify Order Timeline comment

Phase 5: Testing (Day 6)
   └── UAT sandbox → validate → switch to production
```

---

## 📁 Repository Structure

```
shopify-payu-whatsapp-payout/
│
├── README.md                          ← You are here
│
├── docs/
│   ├── SETUP_GUIDE.md                 ← Step-by-step human-readable setup
│   ├── TROUBLESHOOTING.md             ← Common errors + fixes
│   └── AGENT_SOP.md                   ← Standard operating procedure for support agents
│
├── shopify-flow/
│   ├── flow_export.json               ← Importable Shopify Flow workflow (if supported)
│   └── flow_config_reference.md       ← Manual step-by-step Flow configuration guide
│
├── api/
│   ├── payu_smartsend_payload.json    ← PayU Smart Send API request body
│   ├── payu_response_sample.json      ← Sample PayU API success response
│   └── payu_api_headers.md            ← Authorization header setup guide
│
├── whatsapp/
│   ├── interakt_payload.json          ← Interakt Send Template API request body
│   ├── whatsapp_template.txt          ← WhatsApp message template text for Meta approval
│   └── interakt_setup.md              ← Interakt API key + template config guide
│
└── scripts/
    ├── generate_expiry_timestamp.js   ← Utility: auto-calculate 48hr expiry for PayU link
    └── test_payu_connection.sh        ← cURL test script for PayU UAT sandbox
```

---

## ⚡ Quick Start

### Prerequisites

| Requirement | Details |
|---|---|
| Shopify Plan | Basic or above (Shopify Flow available on all plans) |
| PayU Account | Payouts module must be enabled. Contact your PayU Account Manager. |
| Interakt Account | Any paid plan with Template API access |
| WhatsApp Business | Connected via Interakt's WABA |

### Step 1 — Clone This Repo
```bash
git clone https://github.com/your-org/shopify-payu-whatsapp-payout.git
cd shopify-payu-whatsapp-payout
```

### Step 2 — Follow the Setup Guide
Open [`docs/SETUP_GUIDE.md`](docs/SETUP_GUIDE.md) and follow each phase in order.

### Step 3 — Configure Your Credentials
Replace all placeholder values (marked with `YOUR_...`) in the API payload files with your actual keys.

### Step 4 — Test on UAT
Run the sandbox test using [`scripts/test_payu_connection.sh`](scripts/test_payu_connection.sh) before going live.

---

## 🔐 Security Model

| Layer | Mechanism |
|---|---|
| Link Access | OTP sent to registered customer mobile only |
| Amount Integrity | Amount is locked by merchant — customer cannot edit it |
| Link Expiry | 48-hour automatic expiry (configurable) |
| Audit Trail | Every link logged in Shopify Order Timeline |

---

## 🤝 Contributing

Pull requests welcome. For major changes, open an issue first.

---

## ⚠️ Disclaimer

This integration requires live credentials from PayU and Interakt. Always test in the UAT/sandbox environment before switching to production. For financial compliance, consult your payment provider's support team.
