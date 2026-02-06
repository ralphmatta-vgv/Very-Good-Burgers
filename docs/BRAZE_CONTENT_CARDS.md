# Braze Content Cards

Content Cards from Braze are shown on the **Home** screen directly under the **Limited time offer** (Double Smash Deal) promo. They appear in a horizontal scroll.

---

## What’s implemented

- **Subscription:** The app subscribes to Braze content cards at launch and requests a refresh.
- **Placement:** Cards are rendered in a horizontal list under the “LIMITED TIME” promo and above “Quick Actions”.
- **Display:** Each card shows image (if set), title, description, and link text. Taps log a click to Braze; impressions are logged when a card is shown.
- **Filtering:** Control cards, removed cards, and expired cards (by `expiresAt`) are not shown.

---

## How to create a Content Card in Braze

Content Cards are created **inside a Campaign** (or inside a Canvas). They don’t appear as a separate “Content Cards” item in the main campaign list—you choose Content Cards as the **channel** when creating a campaign.

1. In Braze go to **Messaging** → **Campaigns** (or **Engagement** → **Campaigns**, depending on your sidebar), then click **Create Campaign**.
2. When asked for the message type/channel, select **Content Cards** (not “In-App Message” or “Push”). If you don’t see “Content Cards” as an option, your workspace may need Content Cards enabled by Braze.
3. Name the campaign and, in the composer, choose a **card type**: **Classic**, **Captioned Image**, or **Image Only**. The app uses **title**, **description**, **image**, and **link text** from the card.
4. Set **audience** (e.g. segment or test user by external ID).
5. Design the card: upload an image, set title and body, set link text and optional URL.
6. Set **delivery** (e.g. scheduled or action-based/triggered). For testing, target a segment that includes your user or use “Send to test user”.
7. Launch the campaign.

After a refresh (e.g. app launch or pull-to-refresh), cards will appear under the Limited time offer. The app loads cached cards immediately and updates when Braze pushes new data.

---

## Testing

1. Run the app and open the **Home** tab.
2. Create at least one live Content Card in Braze for your user (or segment).
3. Fully close and reopen the app, or wait for the next content-cards refresh, so the new card is fetched.
4. You should see the card(s) in a horizontal list under the blue “Double Smash Deal” promo.

If no cards appear, confirm in Braze that (a) the card is live, (b) the audience includes your user’s external ID, and (c) the user is identified (e.g. after opening the app or logging in).
