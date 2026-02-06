# Braze User ID: UUID and Avoiding Duplicates

## Current behavior

- **New users:** Get a UUID as external ID.
- **Existing users with a legacy id (e.g. `user_1`):** The app calls Braze’s **Rename external ID** REST API so the same profile gets a new UUID, then updates the stored user to that UUID. **No duplicate** is created.

To enable this migration you must pass your Braze **REST API key** (with `users.external_ids.rename` permission) when running the app:

```bash
flutter run --profile --dart-define=BRAZE_REST_API_KEY=your_rest_api_key --dart-define=BRAZE_REST_ENDPOINT=https://rest.fra-02.braze.eu
```

If you don’t set `BRAZE_REST_API_KEY`, the app keeps using the legacy id (e.g. `user_1`) and does not rename.

## If you already have a duplicate (user_1 + UUID)

1. **In Braze:** Merge or delete the extra profile (User Search → find the UUID profile → merge into `user_1` or delete it).
2. **In the app:** Set the REST key and run again so the next launch renames `user_1` → a new UUID in Braze and updates the app to that UUID.
