import Base from "../../base";

class CommonSection extends Base {
  /****** LINKS ******/
  get navMenu() {
    return $('button[title="Show Navigation Menu"]');
  }

  get caseLink() {
    return $("=Cases");
  }

  get menuList() {
    return $("a[title='Select List View']");
  }

  get openCaseLink() {
    return $("span=My Open Cases");
  }

  /****PAGE ACTIONS *****/

  goToCasePage() {
    this.navMenu.click();
    this.caseLink.click();
  }

  goToCaseSearchPage() {
    this.menuList.click();
    this.openCaseLink.click();
  }
}

export default new CommonSection();
