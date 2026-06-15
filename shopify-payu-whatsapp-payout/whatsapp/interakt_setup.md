# Interakt Setup Guide

## Step 1: Get Your API Key

1. Log into [Interakt Dashboard](https://app.interakt.ai)
2. Navigate to **Settings > Developer Settings**
3. Copy your **API Key**
4. In Shopify Flow, add this to your Interakt HTTP request header as:
   ```
   Authorization: Basic YOUR_INTERAKT_API_KEY
   ```

## Step 2: Create and Submit the Template

1. Go to **Templates > Create Template** in Interakt
2. Use the content from `whatsapp_template.txt` in this folder
3. Submit for Meta approval
4. Approval typically takes **24–48 hours**

## Step 3: Note the Template Code Name

After approval, the template appears in Interakt's Template Manager.
Copy the **exact code name** (e.g., `cod_dispute_payout_link`) — this is what goes in your
Interakt JSON payload's `"name"` field. It is case-sensitive.

## Step 4: Configure the Dynamic Button URL

When you created the template with a Dynamic URL button, Interakt and Meta
expect you to inject only the **URL suffix** at runtime (the part after the base domain).

In this integration, we pass the **full PayU link** via `buttonValues["0"][0]`.
Ensure your Interakt template's base URL is configured to accept a full dynamic suffix,
or contact Interakt support to confirm your template's button URL configuration.

## API Rate Limits

Interakt enforces rate limits on API calls. For high-volume dispute scenarios:
- Default: ~10 messages/second
- Contact Interakt support if you need higher throughput

## Troubleshooting Interakt

| Error | Meaning |
|---|---|
| `401` | Wrong API key |
| `403` | Account not authorized to send template messages |
| `422` | Template name doesn't match, or wrong number of variables |
| `400` | Phone number format issue — ensure 10-digit format without +91 |
