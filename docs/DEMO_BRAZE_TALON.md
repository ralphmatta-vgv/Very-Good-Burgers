# Demo Mode: Braze & Talon.one Use Case Testing

This app is built for **demo and internal Braze (and Talon.one) use case testing** at a professional services firm — not for real customers or real payments.

---

## What you have now

### 1. **Emulated purchases (no real payment)**

- **Place Order** in the cart does **not** charge any card. It completes the order locally and **triggers Braze events** so you can test purchase flows.
- When you plug in the real Braze SDK, the same flow will send real **purchase events** and **order_completed** to Braze.

### 2. **Braze events already triggered (when you add the SDK)**

| Trigger | Event | What gets sent (examples) |
|--------|--------|----------------------------|
| **Place Order** | **Purchase** (per item) | `productId`, `price`, `currency`, `quantity`, plus properties: `product_name`, `product_category`, `customizations`, `order_id`, `store_id`, `store_name` |
| **Place Order** | **order_completed** | `order_id`, `subtotal`, `tax`, `total`, `items_count`, `unique_items`, `store_id`, `store_name`, `pickup_time`, `reward_redeemed`, `reward_discount`, `coupon_discount`, `points_earned`, `payment_method` |
| Add to cart | **add_to_cart** | `product_id`, `product_name`, `product_category`, `base_price`, `quantity`, `customizations`, `customization_total`, `total_price` |
| Change quantity in cart | **update_cart_quantity** | `product_id`, `product_name`, `old_quantity`, `new_quantity` |
| Remove from cart | **remove_from_cart** | `product_id`, `product_name`, `quantity`, `total_price` |
| Open item detail | **product_viewed** | `product_id`, `product_name`, `product_category`, `price` |
| Change menu category | **category_viewed** | `category` |
| Change store | **store_selected** | `store_id`, `store_name`, `store_distance` |
| Switch tab | **tab_viewed** | `tab_name` |
| Redeem reward | **reward_redeemed** | `order_id` |
| Earn Bite | **loyalty_point_earned** | `points_earned`, `new_total`, `order_id`, `qualifying_amount` |
| Edit profile | **profile_updated** | `updated_fields` |
| Change payment primary | **payment_method_primary_changed** | `id` |
| Change notification prefs | **notification_preference_changed** | `type`, `enabled` |

### 3. **Braze user identity (no real auth)**

- On app load, the app calls **BrazeService.changeUser(userId)** with the current user’s ID (e.g. `user_1`).
- Profile edits call **BrazeService.setUserAttribute** for `first_name`, `last_name`, `email`, `phone`, `birthday`, plus **loyalty_points**, **available_rewards**, **total_orders**, **last_order_date** after each order.
- So Braze sees a **single demo user** today. There is **no login screen and no real authentication** — the app uses a default/local user so you can test events and attributes without a backend.

---

## What “login” means for demo (optional later)

- **You don’t need real authentication** (no passwords, no OAuth, no backend).
- For **Braze testing**, “login” = **which demo user identity** the app uses (so you can test segments, campaigns, and dashboards with different user IDs).
- **Optional enhancement:** Add a simple **“Demo user”** switcher (e.g. in Profile): enter or pick **User ID**, **First name**, **Email** → on confirm, call **BrazeService.changeUser(userId)** and **setUserAttribute** for name/email. No backend, no password. That lets you switch between “users” (e.g. `user_1`, `user_2`, `demo_exec`) for Braze testing.

---

## Talon.one

- **Talon.one** is for promo/loyalty rules (coupons, points, eligibility). Not wired yet.
- After you optimize the app and add the Braze SDK, you can integrate Talon.one (e.g. validate coupons, sync loyalty rules) and keep sending the same Braze events from the app; Braze will still get purchase and order_completed events for demo use cases.

---

## Next steps (in order)

1. **Optimize the app** — UI/UX, flows, performance (your current focus).
2. **Add Braze SDK** — In `lib/services/braze_service.dart`, replace the `print` / TODO calls with real Braze SDK calls. All event names and properties above stay the same; they’re already the trigger for Braze purchase and custom events.
3. **(Optional)** Add a **demo user switcher** so you can test Braze with different user IDs without real auth.
4. **Talon.one** — When ready, add for coupon/promo logic; keep Braze events as-is for demo testing.

---

## Summary

- **No real payments** — Place Order is already “emulated”; it triggers Braze purchase + order_completed with item name, price, quantity, etc.
- **No real auth** — One demo user today; optional “demo user” switcher later for multi-user Braze testing.
- **You already have a way to trigger** purchase events and order_completed: use the app normally and **Place Order**; once the Braze SDK is added, those events will flow to Braze for demo use case testing.
