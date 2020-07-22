import userList from "../utilities/userList.json";
import CustomError from "../utilities/customErrorHandler.js";

/**
 * Contains shared functions. Each class should extend this base class
 */
export default class Base {
  get searchBar(): WebdriverIO.Element {
    return $("//header/div[2]/div[2]/div/div[2]/div/div[2]/div[2]/div/input");
  }

  login(alias: string): void {
    const user: any = userList.find((data) => data.alias === alias);
    browser.url(user.url);
    $("body.desktop").waitForExist();
    browser.pause(5000);
  }

  loadApp(appName: string): void {
    const view: any = browser.execute(() => {
      if (
        document.querySelectorAll("div.lafStandardLayoutContainer").length > 0
      ) {
        return "standard";
      } else if (
        document.querySelectorAll("div.oneConsoleLayoutContainer2").length > 0
      ) {
        return "console";
      } else {
        return "error";
      }
    });

    switch (view) {
      case "console":
        $("nav.appLauncher").click();
        $(
          "/html/body/div[4]/div[2]/div[2]/div[1]/div[1]/one-app-launcher-menu/div/one-app-launcher-search-bar/lightning-input/div/input"
        ).setValue(appName);
        $(
          "/html/body/div[4]/div[2]/div[2]/div[1]/div[1]/one-app-launcher-menu/div/div[1]"
        ).click();
        browser.pause(5000);
        break;
      case "standard":
        browser.$("one-appnav").shadow$("nav.appLauncher").click();
        $(
          "/html/body/div[4]/div[2]/div/div[1]/div[1]/one-app-launcher-menu/div/one-app-launcher-search-bar/lightning-input/div/input"
        ).setValue(appName);
        $(
          "/html/body/div[4]/div[2]/div/div[1]/div[1]/one-app-launcher-menu/div/div[1]/one-app-launcher-menu-item"
        ).click();
        browser.pause(5000);
        break;
      default:
        throw new CustomError("Invalid view");
        break;
    }
  }
}
