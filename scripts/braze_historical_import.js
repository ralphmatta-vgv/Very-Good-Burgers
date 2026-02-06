#!/usr/bin/env node
/**
 * Braze historical import: reads a JSON export of order history and sends
 * ONLY purchases + order_completed events to Braze. Does NOT send or change
 * user attributes (name, store, ID, etc.) — safe to run on a merged profile.
 *
 * Usage:
 *   BRAZE_REST_API_KEY=your_key BRAZE_REST_ENDPOINT=https://rest.fra-02.braze.eu node scripts/braze_historical_import.js path/to/export.json
 *   node scripts/braze_historical_import.js path/to/export.json --external-id=YOUR_CURRENT_UUID
 *
 * Use --external-id=YOUR_CURRENT_UUID so events attach to your current Braze profile (e.g. after merge).
 * All monetary values are rounded to 2 decimals for Braze.
 */

const fs = require('fs');
const path = require('path');

const BATCH_SIZE = 75; // Braze limit per request for events/purchases

function getArg(name, envName) {
  const env = process.env[envName];
  if (env) return env;
  const prefix = `--${name}=`;
  for (const arg of process.argv.slice(2)) {
    if (arg.startsWith(prefix)) return arg.slice(prefix.length);
  }
  return null;
}

function round2(n) {
  if (typeof n !== 'number' || Number.isNaN(n)) return 0;
  return Math.round(n * 100) / 100;
}

function lineTotal(item) {
  const base = (item.item && typeof item.item.price === 'number') ? item.item.price : 0;
  const custom = (item.customizations || []).reduce((s, c) => s + (typeof c.price === 'number' ? c.price : 0), 0);
  const qty = Math.max(1, parseInt(item.quantity, 10) || 1);
  return round2((base + custom) * qty);
}

function toIsoTime(createdAt) {
  if (typeof createdAt === 'string') return createdAt;
  if (createdAt && typeof createdAt.toISOString === 'function') return createdAt.toISOString();
  return new Date().toISOString();
}

function buildPurchases(externalId, orders) {
  const purchases = [];
  for (const order of orders || []) {
    const orderTime = toIsoTime(order.createdAt);
    const store = order.store || {};
    const storeId = store.id || '';
    const storeName = store.name || '';
    const orderId = order.id || '';

    for (const item of order.items || []) {
      const menuItem = item.item || {};
      const productId = menuItem.id || 'unknown';
      const quantity = Math.max(1, parseInt(item.quantity, 10) || 1);
      const totalPrice = lineTotal(item);
      const customizations = (item.customizations || []).map(c => c.name || c.id).filter(Boolean);

      const productName = menuItem.name || productId;
      purchases.push({
        external_id: externalId,
        product_id: productName,
        currency: 'USD',
        price: round2(totalPrice),
        quantity,
        time: orderTime,
        properties: Object.fromEntries(
          Object.entries({
            product_sku: productId,
            product_name: productName,
            product_category: menuItem.category || '',
            customizations: customizations.length ? customizations : null,
            order_id: orderId,
            store_id: storeId,
            store_name: storeName,
          }).filter(([, v]) => v != null)
        ),
      });
    }
  }
  return purchases;
}

function buildOrderCompletedEvents(externalId, orders) {
  const events = [];
  for (const order of orders || []) {
    const orderTime = toIsoTime(order.createdAt);
    const store = order.store || {};
    const itemsCount = (order.items || []).reduce((s, i) => s + (parseInt(i.quantity, 10) || 1), 0);
    const uniqueItems = (order.items || []).length;

    events.push({
      external_id: externalId,
      name: 'order_completed',
      time: orderTime,
      properties: {
        order_id: order.id || '',
        subtotal: round2(order.subtotal ?? 0),
        tax: round2(order.tax ?? 0),
        total: round2(order.total ?? 0),
        items_count: itemsCount,
        unique_items: uniqueItems,
        store_id: store.id || '',
        store_name: store.name || '',
        pickup_time: order.pickupTime || '',
        reward_redeemed: (order.rewardDiscount || 0) > 0,
        reward_discount: round2(order.rewardDiscount ?? 0),
        coupon_discount: round2(order.couponDiscount ?? 0),
        points_earned: order.pointsEarned ?? 0,
        payment_method: 'card',
      },
    });
  }
  return events;
}

async function postBatch(endpoint, apiKey, body) {
  const url = `${endpoint.replace(/\/$/, '')}/users/track`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  let data;
  try {
    data = JSON.parse(text);
  } catch {
    throw new Error(`Braze API error (${res.status}): ${text}`);
  }
  if (res.status !== 201 && res.status !== 200) {
    throw new Error(`Braze API error: ${JSON.stringify(data)}`);
  }
  if (data.message && data.message !== 'success') {
    throw new Error(`Braze API message: ${data.message} ${JSON.stringify(data.errors || [])}`);
  }
  return data;
}

function getExternalId(data, cliOverride) {
  if (cliOverride) return cliOverride;
  return data.external_id || data.userId || 'user_1';
}

async function main() {
  const filePath = process.argv.find(a => !a.startsWith('--') && a.endsWith('.json')) || process.argv[2];
  const apiKey = getArg('api-key', 'BRAZE_REST_API_KEY');
  const endpoint = getArg('endpoint', 'BRAZE_REST_ENDPOINT');
  const externalIdOverride = getArg('external-id', 'BRAZE_EXTERNAL_ID');

  if (!filePath || !fs.existsSync(filePath)) {
    console.error('Usage: node braze_historical_import.js <export.json> [--api-key=KEY] [--endpoint=URL] [--external-id=UUID]');
    console.error('  --external-id=UUID  Use this Braze user ID (e.g. your current UUID after merge). Default: from JSON.');
    console.error('  Or set BRAZE_REST_API_KEY, BRAZE_REST_ENDPOINT (e.g. https://rest.fra-02.braze.eu)');
    process.exit(1);
  }
  if (!apiKey || !endpoint) {
    console.error('Missing: set BRAZE_REST_API_KEY and BRAZE_REST_ENDPOINT, or pass --api-key= and --endpoint=');
    process.exit(1);
  }

  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  const externalId = getExternalId(data, externalIdOverride);
  const orders = data.orders || [];

  const purchases = buildPurchases(externalId, orders);
  const events = buildOrderCompletedEvents(externalId, orders);

  console.log(`External ID: ${externalId}`);
  console.log(`Orders: ${orders.length}, Purchases: ${purchases.length}, Events: ${events.length}`);

  for (let i = 0; i < purchases.length; i += BATCH_SIZE) {
    const batch = purchases.slice(i, i + BATCH_SIZE);
    await postBatch(endpoint, apiKey, { purchases: batch });
    console.log(`  Purchases ${i + batch.length}/${purchases.length}`);
  }
  for (let i = 0; i < events.length; i += BATCH_SIZE) {
    const batch = events.slice(i, i + BATCH_SIZE);
    await postBatch(endpoint, apiKey, { events: batch });
    console.log(`  Events (order_completed) ${i + batch.length}/${events.length}`);
  }

  console.log('Done. Check Braze user profile for purchases and order_completed events.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
