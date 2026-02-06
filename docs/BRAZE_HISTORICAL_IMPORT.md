# Braze Historical Import (Purchases & Order Events)

Use the script in `scripts/braze_historical_import.js` to backfill **purchases** and **order_completed** events into Braze from a JSON export of your app’s order history.

**Safe for merged profiles:** The script sends **only** events and purchases. It does **not** send or change user attributes (external ID, name, email, favorite store, etc.). Your current Braze profile (ID, store name, attributes) stays as-is. Use `--external-id=YOUR_CURRENT_UUID` so the imported history attaches to your current user.

---

## 1. Get your Braze REST API key and endpoint

- In Braze: **Settings** → **API Keys** (or **Partner Integrations** → **API Keys**).
- Use a **REST API key**, not the SDK/Mobile key (the one in your app’s AppDelegate). Create or copy a key that has **users.track** permission (often labeled “REST API Key”).
- Your **REST endpoint** is based on your cluster, e.g.:
  - `sdk.fra-02.braze.eu` → `https://rest.fra-02.braze.eu`
  - `sdk.iad-01.braze.com` → `https://rest.iad-01.braze.com`

Do **not** use the SDK API key here; use the **REST** key and **REST** endpoint.

---

## 2. Export order history JSON from the app

The script expects a JSON file in this shape:

```json
{
  "external_id": "user_1",
  "orders": [
    {
      "id": "order_abc",
      "store": { "id": "store_1", "name": "Downtown" },
      "pickupTime": "asap",
      "items": [
        {
          "id": "cart_1",
          "item": {
            "id": "burger_classic",
            "name": "Classic Burger",
            "category": "Burgers",
            "price": 9.99
          },
          "customizations": [{ "id": "extra_cheese", "name": "Extra Cheese", "price": 0.99 }],
          "quantity": 2,
          "isRedeemedReward": false
        }
      ],
      "subtotal": 21.97,
      "tax": 1.76,
      "total": 23.73,
      "rewardDiscount": 0,
      "couponDiscount": 0,
      "pointsEarned": 10,
      "createdAt": "2025-02-01T14:30:00.000Z"
    }
  ]
}
```

**Ways to get this JSON:**

- **From the app (easiest):** Open **Order History** in the app and tap the **export** icon (upload/file) in the app bar. The app writes `braze_export.json` to the app’s documents directory and shows the path in a snackbar. On iOS you can copy the file out via Xcode (Window → Devices and Simulators → select device → download container) or the Files app if the app exposes it.
- **By hand:** Use the sample file `scripts/sample_braze_export.json` as a template and replace with real orders (same structure as above).

---

## 3. Run the script

From the project root:

```bash
# Option A: environment variables
export BRAZE_REST_API_KEY="your_rest_api_key_here"
export BRAZE_REST_ENDPOINT="https://rest.fra-02.braze.eu"
node scripts/braze_historical_import.js path/to/your_export.json

# Option B: command-line args (use your current Braze external ID so history attaches to the right profile)
node scripts/braze_historical_import.js path/to/your_export.json \
  --api-key="your_rest_api_key_here" \
  --endpoint="https://rest.fra-02.braze.eu" \
  --external-id="YOUR_CURRENT_BRAZE_UUID"
```

**Important:** If your Braze user is now a UUID (e.g. after merging profiles), pass that UUID with `--external-id=...`. The export file may still say `external_id: "user_1"`; overriding with your current ID ensures the imported events and purchases attach to the correct profile without changing any attributes.

Requirements: **Node 18+** (for `fetch`). No `npm install` needed.

The script will:

- Send one **purchase** per order line item (product_id, price rounded to 2 decimals, quantity, time, plus properties like product_name, order_id, store_id).
- Send one **order_completed** custom event per order (subtotal, tax, total, etc., all monetary values rounded to 2 decimals for Braze).
- **Not** send or change user attributes (name, store, ID, etc.).

Batches of up to 75 items are sent per request to stay within Braze limits.

---

## 4. Verify in Braze

- Open **User Search** and look up the external_id you used (the one you passed with `--external-id` or from the JSON).
- Check **Purchases** and **Custom events** for the backfilled data. Profile attributes (name, favorite store, etc.) are unchanged.

---

## Sample file

See `scripts/sample_braze_export.json` for a minimal valid payload you can edit and run against the script.
