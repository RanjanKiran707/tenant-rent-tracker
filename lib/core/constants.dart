/// Due day given to a new tenant when the user does not choose one.
const int defaultDueDay = 10;

/// uuid of the built-in "Uncategorized" group. Every tenant is in a group; this
/// is where tenants from before groups existed (and the default choice) go.
/// A fixed value, so a fresh install and the schema 1 -> 2 migration agree.
const String uncategorizedGroupUuid = 'uncategorized';
