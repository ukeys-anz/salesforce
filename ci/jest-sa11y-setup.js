import { setup } from "@sa11y/jest";
// Register the sa11y matcher
// Disabled automatic checks due to Jest 30 compatibility issues with @sa11y/jest@6.13.0
// Can still use expect(element).toBeAccessible() manually in tests
setup({ autoCheckOpts: { runAfterEach: false, cleanupAfterEach: true } });
