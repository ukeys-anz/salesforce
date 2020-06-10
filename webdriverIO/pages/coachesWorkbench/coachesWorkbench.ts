import Base from "../base";
/**
 * Handles the base Coaches Workbench app
 */
class CoachesWorkbench extends Base {
  /****** NAV BAR ******/
  get navCases() {
    return $("//div/one-app-nav-bar-item-root[3]");
  }
}

export default new CoachesWorkbench();
