# Production Checkout Routing Incident — FlexyPe Checkout Flow Issue

---

# Incident Overview

## Project Context

Lagorii Kids used a dual-checkout architecture through FlexyPe, where users were dynamically routed to different checkout experiences based on IP-based geolocation.

The checkout setup included:

| User Type | Checkout Flow | Payment Gateway |
|---|---|---|
| Domestic Users | Domestic Checkout | PayU |
| International Users | International Checkout | XPay |

The routing logic depended on:
- user IP address
- checkout segmentation
- geolocation-based routing
- FlexyPe checkout environment

---

# Business Problem

One afternoon, the operations team noticed an unusual business issue:

- website traffic remained stable
- users were actively browsing products
- however, incoming orders suddenly stopped

At the same time:
- abandoned checkout visibility was unusually low
- payment attempts were not appearing properly
- no major frontend deployment had been pushed recently

This created suspicion that users were failing before reaching the payment gateway stage.

---

# Investigation Process

# Step 1 — Funnel Observation

The ecommerce funnel was analyzed to identify where users were dropping.

```text
Homepage Traffic
    ↓
Product Page Visits
    ↓
Add to Cart
    ↓
Checkout Initiation
    ↓
Payment Gateway
    ↓
Order Success
```

## Key Observation

Users were:
- browsing products
- adding items to cart
- attempting checkout

But:
- payment gateway requests were not being triggered
- orders were not being created
- checkout completion suddenly dropped

---

# Step 2 — Manual Testing & Reproduction

The issue was manually tested across:
- mobile devices
- desktop browsers
- multiple user flows

## Discovery

Domestic users were unexpectedly being shown the international checkout page instead of the domestic checkout flow.

---

# Expected vs Actual Checkout Flow

## Expected Checkout Flow

```text
Indian User
    ↓
Domestic Checkout
    ↓
PayU Payment Gateway
    ↓
Successful Payment
    ↓
Order Created
```

---

## Actual Checkout Flow During Incident

```text
Indian User
    ↓
International Checkout
    ↓
XPay Validation Failure
    ↓
Payment Not Initiated
    ↓
Order Not Created
```

---

# Technical Symptoms Observed

| Expected Behavior | Actual Behavior |
|---|---|
| Domestic users routed to domestic checkout | Domestic users routed to international checkout |
| PayU payment gateway initialized | XPay validation failed |
| Payment request processed | Payment flow interrupted |
| Orders successfully created | Orders stopped completely |

---

# Escalation Process

## Step 3 — Cross-Team Escalation

The issue was escalated to the FlexyPe checkout team along with:
- screenshots of the incorrect checkout page
- mobile-device reproductions
- checkout flow observations
- payment failure details

The issue was investigated and resolved by the FlexyPe team.

---

# Resolution

The checkout routing issue was corrected and the proper domestic checkout flow was restored.

Post-resolution validation confirmed:
- domestic users were routed correctly
- PayU payment gateway initialized successfully
- checkout conversions resumed normally
- order flow returned to expected levels

---

# Business Impact

## Operational Impact
- sudden drop in incoming orders
- checkout conversion disruption
- payment routing failure for domestic users

## Customer Impact
- inability to complete transactions
- failed payment flow experience
- checkout interruption during purchase attempts

---

# Key Learnings

## Technical Learnings
- Checkout routing systems require continuous monitoring.
- Payment gateway issues may originate before gateway initialization.
- IP-based checkout segmentation requires validation checks.
- Mobile-device testing is critical during production incidents.

## Product Learnings
- Sudden order drops should trigger immediate funnel investigation.
- Silent checkout failures can directly impact revenue.
- Cross-team escalation is essential for rapid incident resolution.

---

# Skills Demonstrated

## Technical Skills
- Production Incident Investigation
- Ecommerce Funnel Analysis
- Checkout Flow Debugging
- Payment Routing Analysis
- Mobile Flow Reproduction
- Operational Monitoring

## Product & Business Skills
- Root Cause Identification
- Incident Escalation
- Conversion Monitoring
- Revenue Impact Analysis
- Cross-functional Coordination

---

# Final Outcome

The issue was successfully identified, escalated, and resolved through structured production debugging and coordination with the FlexyPe checkout team, restoring normal checkout and payment operations for domestic users.
