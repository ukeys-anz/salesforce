import userList from "../utilities/userList.json";

/**
 * Contains shared functions. Each class should extend this base class
 */
export default class Base {
  get searchBar(): any {
    return $("//header/div[2]/div[2]/div/div[2]/div/div[2]/div[2]/div/input");
  }

  login(alias: string): void {
    const user: any = userList.find((data) => data.alias === alias);
    browser.url(user.url);
    $("body.desktop").waitForExist();
    browser.pause(5000);
  }

  loadApp(appName: string): void {
    $("div.appLauncher").click();
    $(
      "/html/body/div[4]/div[2]/div[2]/div[1]/div[1]/one-app-launcher-menu/div/one-app-launcher-search-bar/lightning-input/div/input"
    ).setValue(appName);
    $(
      "/html/body/div[4]/div[2]/div[2]/div[1]/div[1]/one-app-launcher-menu/div/div[1]"
    ).click();
    browser.pause(5000);
  }
}
