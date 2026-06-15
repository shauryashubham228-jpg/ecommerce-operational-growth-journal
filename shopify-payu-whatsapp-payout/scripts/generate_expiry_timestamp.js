/**
 * generate_expiry_timestamp.js
 * 
 * Utility: Generates an ISO 8601 timestamp exactly 48 hours from now.
 * Use this value as the `expiryDate` field in your PayU Smart Send API payload.
 *
 * Usage (Node.js):
 *   node generate_expiry_timestamp.js
 *
 * Usage (browser console):
 *   Copy the getExpiryTimestamp() function and run it.
 *
 * Usage in Shopify Flow:
 *   Shopify Flow does not support inline JavaScript execution.
 *   Instead, you can:
 *   Option A — Hardcode a rolling date (update weekly): "2026-06-20T23:59:59Z"
 *   Option B — Set up a separate serverless function (e.g., Vercel/Netlify) that
 *               returns the expiry timestamp and call it as a pre-step HTTP request
 *               in Shopify Flow before the PayU call.
 *   Option C — Contact PayU support to confirm if omitting expiryDate defaults to
 *               their standard expiry window (usually 7 days).
 */

/**
 * Returns an ISO 8601 timestamp 48 hours from the current time.
 * @param {number} hoursFromNow - Number of hours until expiry (default: 48)
 * @returns {string} ISO 8601 formatted expiry timestamp
 */
function getExpiryTimestamp(hoursFromNow = 48) {
  const now = new Date();
  const expiry = new Date(now.getTime() + hoursFromNow * 60 * 60 * 1000);
  return expiry.toISOString().replace(/\.\d{3}Z$/, 'Z'); // Remove milliseconds
}

// Example outputs:
console.log('48-hour expiry:', getExpiryTimestamp(48));
console.log('24-hour expiry:', getExpiryTimestamp(24));
console.log('72-hour expiry:', getExpiryTimestamp(72));

// Export for use as a module
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { getExpiryTimestamp };
}

/*
 * SAMPLE OUTPUT:
 * 48-hour expiry: 2026-06-15T14:30:00Z
 * 24-hour expiry: 2026-06-14T14:30:00Z
 * 72-hour expiry: 2026-06-16T14:30:00Z
 *
 * Paste the 48-hour output into the expiryDate field of your PayU payload:
 *   "expiryDate": "2026-06-15T14:30:00Z"
 */
