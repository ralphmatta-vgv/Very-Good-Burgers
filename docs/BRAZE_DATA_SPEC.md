# Braze Data Structure — Approved Tracking Plan

This doc reflects the **approved data tracking plan** (see `braze_data_tracking_plan.csv`). Only items marked **Send to Braze = Y** are sent. Messaging preferences (Push/Email/SMS) are mapped to **Braze subscription groups** — see `BRAZE_SUBSCRIPTION_GROUPS.md`.

---

## 1. User identity

| Braze concept | Value we send | When |
|---------------|----------------|------|
| **External User ID** | `user.id` (UUID v4) | App init; new users get a UUID; legacy ids (e.g. `user_1`) are renamed to a new UUID in Braze via REST API then updated locally so the same profile is kept (no duplicate). Requires `BRAZE_REST_API_KEY` dart-define. |

---

## 2. Standard attributes (sent)

| Attribute | Source | When |
|-----------|--------|------|
| `first_name` | `user.firstName` | Profile update; initial load |
| `last_name` | `user.lastName` | Profile update; initial load |
| `email` | `user.email` | Profile update; initial load |

---

## 3. Custom attributes (sent)

| Key | Type | When we set it |
|-----|------|----------------|
| `loyalty_points` | int | After each order |
| `available_rewards` | int | After each order |
| `total_orders` | int | After each order |
| `last_order_date` | string (e.g. `Feb 05 2026`) | After each order; formatted for Braze segmentation |
| `phone` | string | Profile update |
| `birthday` | string | Profile update |
| `has_payment` | boolean | When user adds payment (default false until then) |
| `favorite_store` | string | Descriptive: store name + address (e.g. `VGB Downtown — 123 Main Street`) |
| `profile_image_url` | string or null | When user updates profile photo; set to a public URL when you have image upload, else null. To enable: upload the image to your CDN/storage, then call `updateProfile({'profilePhotoFile': filename, 'profile_image_url': publicUrl})` so Braze receives the URL. |
| `favorite_burger` | string | Derived from order history (most ordered burger) |
| `favorite_drink` | string | Derived from order history (most ordered drink) |
| `favorite_combo` | string | Derived from order history (most ordered combo) |
| `favorite_dessert` | string | Derived from order history (most ordered dessert) |
| `total_earned_rewards` | int | Lifetime Bites/rewards earned (after each qualifying order) |
| `total_redeemed_rewards` | int | Lifetime rewards redeemed (after each redemption) |
| `total_coupons_redeemed` | int | Lifetime coupon redemption count |
| `average_cart_value` | double | Updated every order (average order total) |

---

## 4. Purchase events (sent)

One **per line item** on Place Order.

- **product_id** = human-readable product name (e.g. `Classic Smash`), **price** (line total), **currency** (USD), **quantity**
- **Properties:** `product_sku` (internal id), `product_name`, `product_category`, `customizations`, `order_id`, `store_id`, `store_name`

---

## 5. Custom events — SENT to Braze (Y)

| Event name | When | Properties |
|------------|------|------------|
| **add_to_cart** | Add to cart | product_id, product_name, product_category, base_price, quantity, customizations, customization_total, total_price |
| **update_cart_quantity** | Change qty in cart | product_id, product_name, old_quantity, new_quantity |
| **store_selected** | Change store | store_id, store_name, store_distance |
| **order_completed** | Place order | order_id, subtotal, tax, total, items_count, unique_items, store_id, store_name, pickup_time, reward_redeemed, reward_discount, coupon_discount, points_earned, payment_method |
| **reward_redeemed** | Place order with reward | order_id |
| **loyalty_point_earned** | Place qualifying order | points_earned, new_total, order_id, qualifying_amount |
| **payment_method_primary_changed** | Tap set Primary | id |
| **notification_preference_changed** | Toggle Push/Email/SMS | type (push\|email\|sms), enabled |
| **LTO coupon redeemed** | User redeems homepage LTO (Double Smash); apply at checkout | (none or add as needed) |

---

## 6. Custom events — NOT SENT to Braze (N)

We do **not** send these to Braze (per tracking plan):

- `remove_from_cart`
- `product_viewed`
- `category_viewed`
- `tab_viewed`
- `profile_updated`

---

## 7. Messaging preferences & subscription groups (not in data plan)

Braze tracks **messaging preferences** via **subscription groups** (out of the box). We do **not** send these as custom attributes; we **map the app toggles to Braze subscription groups** so Braze can respect them when sending messages. **Push is a key channel to test.**

- **Push Notifications** toggle → Braze **push subscription group** (Subscribed / Unsubscribed)
- **Email Offers** toggle → Braze **email subscription group**
- **SMS Offers** toggle → Braze **SMS subscription group**

Details and implementation notes: **`BRAZE_SUBSCRIPTION_GROUPS.md`**.

---

## Enabling the real Braze SDK

Right now all tracking goes through **BrazeTracking** → **BrazeService** (console logging). To send data to Braze:

1. **Add the SDK:** In `pubspec.yaml`, uncomment `braze_plugin: ^16.0.0` and run `flutter pub get`.
2. **Initialize in `main.dart`** with your Braze API key and endpoint (see [Braze Flutter docs](https://www.braze.com/docs/developer_guide/platform_integration_guides/flutter/)). After `Braze.initialize(...)`, call `BrazeService.setInitialized(true)`.
3. **Uncomment the real Braze calls** in `lib/services/braze_service.dart` (replace the `print` blocks with the appropriate `Braze.*` methods from `braze_plugin`).
4. **Subscription groups:** If your dashboard uses subscription group IDs, use the Braze API that sets subscription state by group ID; the current stubs set global push/email/SMS state.
