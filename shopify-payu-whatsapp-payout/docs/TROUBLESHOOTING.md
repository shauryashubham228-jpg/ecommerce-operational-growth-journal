# 🔧 Troubleshooting Guide

## How to Read Shopify Flow Logs

1. Go to **Shopify Admin > Apps > Shopify Flow**
2. Open your **"Send PayU COD Payout Link"** workflow
3. Click the **Activity** tab
4. Click any run row to see the detailed step-by-step log

---

## PayU API Errors (Step 1 in Flow)

| HTTP Status Code | Meaning | Fix |
|---|---|---|
| `200` or `201` | ✅ Success | Continue to check Step 2 |
| `400` | Bad request payload | Check JSON syntax. Look at Response Body — PayU returns the specific field that's wrong (e.g., `"Invalid Phone Number"` or `"Amount cannot be empty"`) |
| `401` | Unauthorized | Your `Authorization: Bearer` JWT token is expired or incorrect. Generate a new token from your PayU Payouts Dashboard |
| `403` | Forbidden | Your PayU account does not have Smart Send activated. Contact your PayU Account Manager |
| `422` | Unprocessable entity | The `custMobile` field may be missing the country code, or `merchantRefId` has special characters. Ensure phone is 10 digits (no +91 prefix in this field) |
| `500` | PayU server error | Wait 5 minutes and retry. If persistent, contact PayU support |

### Checking the PayU Response Variable

If PayU returns `200` but Interakt still fails, the issue is likely the link variable not being passed correctly.

In the Flow log, click the **PayU HTTP card** and expand **Output Variables**. Look for:
```
http.response.body.data.payoutLink
```
This should contain a real URL like `https://payu.in/s/XXXXX`. If it's empty or shows a different path, your PayU account may return the link under a different key — check the full response body and update the variable path in your Interakt payload.

---

## Interakt API Errors (Step 2 in Flow)

| HTTP Status Code | Meaning | Fix |
|---|---|---|
| `200` | ✅ Success | Message delivered to WhatsApp |
| `400` | Bad payload | Usually a mismatched number of `bodyValues`. Count your `{{N}}` placeholders in the Meta template and ensure `bodyValues` array has exactly the same count |
| `401` or `403` | Auth failed | Your `Authorization: Basic` API key is wrong or missing. Regenerate from Interakt > Settings > Developer Settings |
| `422` | Template name mismatch | The `"name"` field in your payload does not exactly match the template code name in Interakt. Copy-paste the exact string from Interakt's Template Manager — it is case-sensitive |
| `429` | Rate limit | You're sending too many messages too fast. Interakt has per-second rate limits on API calls. Add a brief delay or contact Interakt support to increase your limit |

---

## Common Flow Issues

### ❌ Button appears in More Actions but nothing happens when clicked

**Cause:** The Shopify Flow workflow is not set to **Active**.
**Fix:** Open the workflow in Shopify Flow and toggle it to **Active**.

---

### ❌ WhatsApp message arrives but the payout link button is missing or broken

**Cause:** The `buttonValues["0"]` field is empty, meaning `http.response.body.data.payoutLink` resolved to null.
**Fix:** Check the PayU step log to confirm the link was generated. If yes, ensure the variable path in the Interakt JSON exactly matches the PayU response structure.

---

### ❌ PayU link opens but shows ₹0 as the refund amount

**Cause:** The Shopify variable `order.totalPriceSet.shopMoney.amount` returned `null` or `0`.
**Fix:** This happens if the test order has no line items or if it was created as a draft without finalizing. Create a proper test order with at least one product and a COD payment method selected.

---

### ❌ Shopify Timeline comment appears but shows empty link

**Cause:** The timeline step runs before the PayU step finishes (race condition in Flow).
**Fix:** Ensure your steps are strictly sequential (not parallel) in Shopify Flow. Delete and re-add the steps in the correct order: PayU first → Interakt second → Timeline comment third.

---

### ❌ Customer says they didn't receive the WhatsApp message

**Checklist:**
1. Confirm `order.customer.phone` is populated on the order (not empty)
2. Confirm the phone number is registered on WhatsApp
3. Check Interakt's **Message Logs** dashboard for delivery status
4. If the number has never messaged your WhatsApp Business account, the customer may have a 24-hour messaging window restriction. Use the pre-approved **Utility Template** category (which bypasses this restriction)

---

## Testing Checklist Before Going Live

- [ ] PayU UAT returns `200` with a valid `payoutLink` URL
- [ ] WhatsApp message arrives on test phone with correct name, amount, and order number
- [ ] Payout link opens in browser (not app) with correct ₹ amount displayed
- [ ] OTP is sent to the registered mobile number when "Send OTP" is clicked
- [ ] OTP entry screen accepts the correct code and shows UPI entry fields
- [ ] Shopify Order Timeline shows the auto-generated comment with the link
- [ ] Flow Activity Log shows all 3 steps as green/success

---

## Getting Help

| Issue Type | Contact |
|---|---|
| PayU API / Smart Send activation | PayU Account Manager or [PayU Developer Docs](https://docs.payu.in) |
| Interakt API / Template approval | [Interakt Support](https://www.interakt.shop/help) |
| Shopify Flow issues | [Shopify Help Center - Flow](https://help.shopify.com/en/manual/shopify-flow) |
| Admin Buttons app | Contact the app developer via Shopify App Store listing |
