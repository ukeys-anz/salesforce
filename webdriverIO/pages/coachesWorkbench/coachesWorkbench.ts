import Base from "../base";
/**
 * Handles the base Coaches Workbench app
 */
class CoachesWorkbench extends Base {
  /****** NAV BAR ******/
  get navCases() {
    return $(
      "/html/body/div[4]/div[1]/section/header/div[3]/one-appnav/div/one-app-nav-bar/nav/div/one-app-nav-bar-item-root[3]"
    );
  }
}

export default new CoachesWorkbench();
