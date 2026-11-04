# Rent Book v2.1.0 (build 3)

Web support, responsive layout, and Firebase Hosting support.

## What's new

- **Web Support**: Rent Book can now run on modern web browsers.
  - Desktop browsers show a realistic responsive mobile phone mockup frame with dark backdrop.
  - Mobile browsers and smaller screens render directly edge-to-edge as a native mobile app.
- **Dependency Injection**: Architecture updated to support cross-platform repositories and services cleanly.
- **Firebase Hosting**: Hosting configuration added for deployment.

---

# Rent Book v2.0.0 (build 2)

Groups arrive. With many tenants, Home now shows **groups** instead of one long list, and a recorded payment can be corrected. Android only.

## What's new

- **Groups**: organise tenants into groups such as "Block A" or "Ground floor".
  - Home shows one card per group: its name, number of tenants, the most urgent status, and the money still to receive this month. Groups that need attention are at the top.
  - Tap a group to see its tenants. Tap a tenant to open Tenant Detail, as before.
  - Add, rename and delete groups. A group can be deleted only when it has no active tenants.
  - Move a tenant to another group from Tenant Detail. Rent, months and payments are not affected.
  - Add Tenant has a Group field, preselected to the group you came from.
- **Uncategorized**: the built-in group. Every tenant you already have is placed here automatically when you update, so nothing is lost. It cannot be renamed or deleted, and it shows on Home only while it has tenants.
- **Edit a payment**: tap a payment line on Tenant Detail to change its amount or the date it was received. The month it pays for stays the same, and the month's status and balance update by themselves. A payment cannot be dated after today. Payments of archived tenants stay read-only.
- **Edit the tenant name** from Tenant Detail.
- **History**: a month that is fully paid moves to **History** (renamed from "Earlier months"). When nothing is pending, Tenant Detail says "No pending due".
- **Full-screen pages** for Edit payment and Move to group, with bigger fields and buttons.
- **Keyboard closes** when you tap anywhere outside a text field.
- **Portrait only**: the app no longer rotates.
- **Home** no longer has the "Add a tenant" button. Open a group, then add the tenant there.

## Updating from 1.0

- Your data is kept. On first launch the app upgrades its database and puts all existing tenants (including archived ones) in **Uncategorized**.
- The upgrade cannot be undone: once on 2.0, going back to 1.0 is not supported.

## Known limits

- Overpayment is not carried forward to the next month.
- No restore for archived tenants.
- The Archived list in Settings is not grouped.
- A payment can be edited but not deleted; Undo, right after recording, is the only way to remove one.
- No cloud backup yet. Uninstalling the app removes your data.

## Play Store "What's new"

**English**
> Groups: organise tenants into groups like Block A, and see each group's status and dues on Home. You can now edit a payment's amount and date, rename a tenant, and move a tenant between groups. Your existing tenants are placed in Uncategorized automatically.

**ಕನ್ನಡ**
> ಗುಂಪುಗಳು: ಬಾಡಿಗೆದಾರರನ್ನು ಬ್ಲಾಕ್ A ನಂತಹ ಗುಂಪುಗಳಲ್ಲಿ ಜೋಡಿಸಿ, ಪ್ರತಿ ಗುಂಪಿನ ಸ್ಥಿತಿ ಮತ್ತು ಬಾಕಿಯನ್ನು ಮುಖಪುಟದಲ್ಲಿ ನೋಡಿ. ಈಗ ಪಾವತಿಯ ಮೊತ್ತ ಮತ್ತು ದಿನಾಂಕವನ್ನು ತಿದ್ದಬಹುದು, ಬಾಡಿಗೆದಾರರ ಹೆಸರನ್ನು ಬದಲಿಸಬಹುದು, ಮತ್ತು ಬಾಡಿಗೆದಾರರನ್ನು ಒಂದು ಗುಂಪಿನಿಂದ ಇನ್ನೊಂದಕ್ಕೆ ಸರಿಸಬಹುದು. ನಿಮ್ಮ ಈಗಿರುವ ಬಾಡಿಗೆದಾರರು ಸ್ವಯಂಚಾಲಿತವಾಗಿ "ವರ್ಗೀಕರಿಸದ" ಗುಂಪಿನಲ್ಲಿ ಇರುತ್ತಾರೆ.

---

# Rent Book v1.0.0 (build 1)

First release of Rent Book, a simple rent tracker for rental property owners. Android only.

- **Tenants**, **monthly status**, **payments** (partial and overpayment), **rent changes** from next month, **archive**, English and Kannada, larger text and big buttons, fully offline.
