/**
 * Mapping of Git branch names to corresponding Slack groups.
 *
 * This object is used to determine which Slack group should be notified
 * based on the target branch name during automation (e.g., in backmerge workflows).
 * We can create different group for different teams.
 *
 * Keys represent branch names (e.g., "epic/anzx-bau"), and
 * values are the Slack group identifiers (e.g., "sf-bau").
 *
 * Example:
 * {
 *   "epic/anzx-bau": "sf-bau"
 * }
 *
 * If a branch is not listed here, it will default to "none" in the output.
 */
const slackGroupMapping = {
  release: "sf-plat-engineers",
  develop: "sf-plat-engineers",
  "epic/anzx-bau": "sf-bau",
  "epic/cmos-a": "sf-cmos",
  "epic/cmos-main": "sf-cmos",
  "epic/imtv1": "sf-quantum",
  "epic/blm": "sf-plat-engineers"
};

export { slackGroupMapping };
