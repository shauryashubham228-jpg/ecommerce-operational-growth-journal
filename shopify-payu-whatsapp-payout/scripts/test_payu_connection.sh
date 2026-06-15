#!/bin/bash

# =============================================================================
# test_payu_connection.sh
# 
# Tests your PayU Smart Send API connection against the UAT sandbox.
# Run this BEFORE going live to confirm your credentials and payload work.
#
# Usage:
#   chmod +x test_payu_connection.sh
#   ./test_payu_connection.sh
#
# Prerequisites:
#   - curl installed (pre-installed on macOS/Linux)
#   - Your PayU UAT JWT token
# =============================================================================

# -------------------------------------------------------
# CONFIGURE THESE VALUES BEFORE RUNNING
# -------------------------------------------------------
PAYU_UAT_TOKEN="YOUR_PAYU_UAT_JWT_TOKEN"
TEST_CUSTOMER_NAME="Test Customer"
TEST_CUSTOMER_MOBILE="9999999999"   # Use YOUR own number for the test
TEST_ORDER_ID="TEST_ORDER_001"
TEST_AMOUNT="100.00"

# Auto-generate a 48-hour expiry timestamp
EXPIRY=$(node -e "
  const now = new Date();
  const exp = new Date(now.getTime() + 48 * 60 * 60 * 1000);
  console.log(exp.toISOString().replace(/\.\d{3}Z\$/, 'Z'));
" 2>/dev/null || echo "2099-12-31T23:59:59Z")

# -------------------------------------------------------
# PayU UAT Endpoint
# -------------------------------------------------------
ENDPOINT="https://uatoneapi.payu.in/payout/v2/smartSend/link"

# -------------------------------------------------------
# Build the Payload
# -------------------------------------------------------
PAYLOAD=$(cat <<EOF
{
  "amount": "${TEST_AMOUNT}",
  "merchantRefId": "SHOPIFY_COD_${TEST_ORDER_ID}",
  "custName": "${TEST_CUSTOMER_NAME}",
  "custMobile": "${TEST_CUSTOMER_MOBILE}",
  "description": "UAT Test - COD Dispute Refund for Order ${TEST_ORDER_ID}",
  "expiryDate": "${EXPIRY}"
}
EOF
)

# -------------------------------------------------------
# Execute the Test
# -------------------------------------------------------
echo ""
echo "========================================"
echo "  PayU Smart Send API — UAT Test"
echo "========================================"
echo ""
echo "Endpoint:   ${ENDPOINT}"
echo "Amount:     ₹${TEST_AMOUNT}"
echo "Customer:   ${TEST_CUSTOMER_NAME} (${TEST_CUSTOMER_MOBILE})"
echo "Reference:  SHOPIFY_COD_${TEST_ORDER_ID}"
echo "Expiry:     ${EXPIRY}"
echo ""
echo "Sending request..."
echo ""

RESPONSE=$(curl -s -w "\n\nHTTP_STATUS:%{http_code}" \
  -X POST "${ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${PAYU_UAT_TOKEN}" \
  -d "${PAYLOAD}")

# Extract status code and body
HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS:" | sed 's/HTTP_STATUS://')
RESPONSE_BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS:/d')

echo "========================================"
echo "  Response"
echo "========================================"
echo "HTTP Status: ${HTTP_STATUS}"
echo ""
echo "Response Body:"
echo "${RESPONSE_BODY}" | python3 -m json.tool 2>/dev/null || echo "${RESPONSE_BODY}"
echo ""

# -------------------------------------------------------
# Interpret the Result
# -------------------------------------------------------
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "201" ]; then
  PAYOUT_LINK=$(echo "$RESPONSE_BODY" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('data', {}).get('payoutLink', 'NOT FOUND'))
except:
    print('PARSE ERROR')
" 2>/dev/null)

  echo "========================================"
  echo "  ✅ SUCCESS"
  echo "========================================"
  echo ""
  echo "Payout Link Generated:"
  echo "${PAYOUT_LINK}"
  echo ""
  echo "Shopify Flow Variable to Use:"
  echo "  {{http.response.body.data.payoutLink}}"
  echo ""
  echo "Next Steps:"
  echo "  1. Verify a WhatsApp message arrives on ${TEST_CUSTOMER_MOBILE}"
  echo "  2. Click the link and confirm OTP flow works"
  echo "  3. Once confirmed, switch to production endpoint:"
  echo "     https://payouts.payumoney.com/payout/v2/smartSend/link"
  echo ""
else
  echo "========================================"
  echo "  ❌ FAILED — HTTP ${HTTP_STATUS}"
  echo "========================================"
  echo ""
  echo "Common Fixes:"
  case "$HTTP_STATUS" in
    401) echo "  → Your JWT token is expired or incorrect. Get a new one from PayU Dashboard." ;;
    400) echo "  → Check payload fields. PayU response shows the specific invalid field." ;;
    403) echo "  → Smart Send is not activated on your account. Contact your PayU Account Manager." ;;
    422) echo "  → custMobile format issue or merchantRefId has invalid characters." ;;
    500) echo "  → PayU server error. Try again in 5 minutes or contact PayU support." ;;
    *)   echo "  → See response body above for details." ;;
  esac
  echo ""
  echo "Docs: https://docs.payu.in/payout/v2/smartSend/link"
fi
