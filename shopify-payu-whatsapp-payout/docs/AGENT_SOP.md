# 👩‍💼 Agent Standard Operating Procedure (SOP)
## Issuing a COD Dispute Refund via PayU WhatsApp Payout Link

**For:** Customer Support Agents  
**Version:** 1.0  
**Last Updated:** June 2026

---

## When to Use This Process

Use this workflow when:
- A customer disputes a **Cash on Delivery (COD)** order
- The customer wants a **bank/UPI refund** instead of store credit or replacement
- The order is confirmed as delivered and payment was collected by the courier

Do **not** use this for:
- Online paid orders (use Shopify's native Refund button instead)
- Orders where the courier has not yet delivered
- Partial item disputes where only some items are being returned (see Step 3 below for partial amount handling)

---

## Step-by-Step Process

### Step 1 — Verify the Dispute

Before initiating any refund link:

1. Open the order in **Shopify Admin > Orders**
2. Confirm the order is a **COD order** (payment method shows "Cash on Delivery")
3. Confirm delivery: check the courier tracking or confirm with the customer
4. Note the **total order amount** shown on the order page
5. Add an internal note to the order: *"Customer disputed. Reviewing for payout link."*

---

### Step 2 — Determine the Refund Amount

| Dispute Type | Action |
|---|---|
| Full order refund | Use the total order amount (system auto-fills this) |
| Partial refund (1 item from multi-item order) | Calculate the per-item amount manually |
| Damaged/defective product | Confirm with supervisor before proceeding |

> ⚠️ **Partial refunds:** The system auto-fills the **full order total**. If the dispute is for only part of the order, note the correct partial amount before clicking the button — you will need to inform the customer of the correct amount to expect.

---

### Step 3 — Trigger the Payout Link

1. Open the disputed COD order in Shopify Admin
2. Click **"More actions"** at the top right of the order page
3. Click **"Send PayU COD Payout Link"**
4. Wait **5–10 seconds**

> The system will automatically:
> - Generate a secure OTP-locked payout link via PayU
> - Send a WhatsApp message to the customer's registered phone number
> - Log the link in this order's Timeline (scroll down to see it)

---

### Step 4 — Confirm Delivery to Customer

After clicking the button, send the customer a follow-up message (via your support channel):

**Template message to send manually (if needed):**
```
Hi [Customer Name], we have initiated your COD refund for Order [Order ID].

You will receive a WhatsApp message from us shortly with a secure link. Please:
1. Click the link in the WhatsApp message
2. Verify using the OTP sent to your mobile
3. Enter your UPI ID or bank account details
4. You will receive the amount (₹[Amount]) instantly.

The link is valid for 48 hours. If you face any issues, please contact us.
```

---

### Step 5 — Confirm Completion

Check the **Order Timeline** in Shopify (scroll down on the order page). You should see an automatic entry like:

```
📩 PayU COD Payout Link Generated.
• Amount Locked: ₹[Amount]
• Customer Mobile: [Phone]
• Status: Dispatched automatically via WhatsApp (Interakt).
• Reference Link: https://payu.in/s/XXXXX
```

This confirms the link was sent. Add your own timeline note:
```
Agent [Your Name]: Payout link sent. Awaiting customer claim. Dispute acknowledged.
```

---

### Step 6 — Close the Dispute

Once the customer claims their refund (PayU will notify you via webhook or email):

1. Go back to the Shopify order
2. Add a final timeline note: *"PayU Payout claimed by customer. Dispute resolved. [Date]"*
3. Mark the order with an internal tag: `cod-refund-issued`
4. Close the support ticket

---

## Important Rules

| Rule | Reason |
|---|---|
| **Never click the button twice for the same order** | Each click generates a new unique link and triggers a new WhatsApp message — this confuses the customer and wastes your PayU wallet balance |
| **Always check the Timeline before clicking** | If a payout link comment already exists, the link was already sent. Contact the customer instead of re-sending |
| **Do not share the link yourself** | The system sends it automatically via WhatsApp. If the customer says they didn't receive it, re-send from the Interakt dashboard, not by copying from the Timeline |
| **Partial refund requests need supervisor approval** | Because the system auto-fills the full order total, adjustments must be pre-approved |

---

## Escalation

If the system fails (no WhatsApp received, no Timeline comment after 30 seconds):

1. Check Shopify Flow logs: **Apps > Shopify Flow > Activity**
2. Share the error code with your team lead
3. As a fallback, manually create the payout link in the **PayU Payouts Dashboard > Make a Transfer > Smart Send**
4. Manually send the link to the customer via WhatsApp Business
5. Document the manual action in the order Timeline
