import Base from "../base";
/**
 * Handles the base Coaches Workbench app
 */
class CoachesWorkbench extends Base {
  /****** NAV BAR ******/
  get navHome() {
    return $("//div/one-app-nav-bar-item-root[1]");
  }

  get navCases() {
    return $("//div/one-app-nav-bar-item-root[3]");
  }

  get myOpenCaseSearch() {
    return $(
      "//section/div/div/div[1]/div[2]/div/div/div[1]/div[2]/div[2]/force-list-view-manager-search-bar/div/lightning-input/div/input"
    );
  }
}

export default new CoachesWorkbench();
