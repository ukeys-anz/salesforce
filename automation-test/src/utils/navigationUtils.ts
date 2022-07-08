import ConsoleAppNavigation from "pageObjects/consoleAppNavigation";
import AppLauncher from "pageObjects/appLauncher";
import HomePage from "pageObjects/homePage";
import AppsDefinition from "../constants/appsDefinition";
import OneAppLauncherMenuItem from "pageObjects/oneAppLauncherMenuItem";
import { URL } from "url";

export type AppLauncherSearchResults = [
  OneAppLauncherMenuItem | "No results",
  OneAppLauncherMenuItem | "No results"
];

const closeConsoleNavMainTabs = async (): Promise<void> => {
  const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);
  const tabBarItems = await consoleAppNavigationRoot.getTabBarItems();

  if (tabBarItems && tabBarItems.length > 0) {
    tabBarItems.forEach(async (item) => {
      await item.closeTab();
    });
  }
};

export const searchInAppLauncher = async (
  searchText: string
): Promise<AppLauncherSearchResults> => {
  // first decide which type of app the test user is in, Standard or Console
  const appLauncherRoot = await utam.load(AppLauncher);

  // if user is in Console app view
  if (await appLauncherRoot.isInConsoleApp()) {
    await appLauncherRoot.openConsoleAppLauncher();
    await browser.pause(1000);
    await appLauncherRoot.search(searchText);
  }
  // if user is in Standard app view
  else {
    // in Standard app, open App Launcher
    const homePageRoot = await utam.load(HomePage);
    const navigationBar = await homePageRoot.getNavigationBar();
    await navigationBar.expandAppLauncher();
    await browser.pause(1000);
    await appLauncherRoot.search(searchText);
  }

  await browser.pause(1000);

  const results: AppLauncherSearchResults = ["No results", "No results"];

  const appResult = await appLauncherRoot.getAppResult();
  if (appResult) {
    results[0] = appResult;
  }

  const itemResult = await appLauncherRoot.getItemResult();
  if (itemResult) {
    results[1] = itemResult;
  }

  return results;
};

const searchAndOpenApp = async (appName: string): Promise<void> => {
  const appLauncherRoot = await utam.load(AppLauncher);

  // search app by name and click and redirect
  await browser.pause(1000);
  await appLauncherRoot.search(appName);
  await browser.pause(1000);
  await appLauncherRoot.selectAppAndRedirect();
  await browser.pause(2000);
};

const openConsoleAppTabHome = async (tabName: string): Promise<void> => {
  // user is in redirected Console app now
  await closeConsoleNavMainTabs();
  await browser.pause(1000);

  const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);

  if (!(await consoleAppNavigationRoot.isCurrentTab(tabName))) {
    // redirect user to tab (tab home may not render correctly sometimes, e.g. console left side bar is present)
    await consoleAppNavigationRoot.redirectToTab(tabName);
  }

  // click to force redirect to and open current tab home page
  await consoleAppNavigationRoot.redirectToCurrentTabHome();
};

const openStandardAppTabHome = async (tabName: string): Promise<void> => {
  const homePageRoot = await utam.load(HomePage);
  const navigationBar = await homePageRoot.getNavigationBar();
  const appNavBar = await navigationBar.getAppNavBar();
  const navItem = await appNavBar.getNavItem(tabName);

  if (tabName === "Home") {
    tabName = "home";
  }
  await navItem.clickAndWaitForUrl(tabName);
};

export const navigateToAppAndTab = async (
  appName: string,
  tabName: string
): Promise<void> => {
  const redirectToAppType = AppsDefinition.get(appName)!.type;

  // first decide which type of app the test user is in, Standard or Console
  const appLauncherRoot = await utam.load(AppLauncher);

  // if user is in Console app view
  if (await appLauncherRoot.isInConsoleApp()) {
    if (redirectToAppType === "Console") {
      if (!(await appLauncherRoot.isCurrentApp(appName))) {
        await appLauncherRoot.openConsoleAppLauncher();
        await browser.pause(1000);
        await searchAndOpenApp(appName);
      }

      await openConsoleAppTabHome(tabName);
    } // if redirectTo app is Standard App
    else {
      await appLauncherRoot.openConsoleAppLauncher();
      await searchAndOpenApp(appName);
      await openStandardAppTabHome(tabName);
    }
  } // if user is in Standard app view
  else {
    // in Standard app, open App Launcher
    const homePageRoot = await utam.load(HomePage);
    const navigationBar = await homePageRoot.getNavigationBar();
    await navigationBar.expandAppLauncher();

    await searchAndOpenApp(appName);

    if (redirectToAppType === "Console") {
      await openConsoleAppTabHome(tabName);
    } else {
      await openStandardAppTabHome(tabName);
    }
  }

  await browser.pause(5000);
};

export const openTabHomeInCurrentApp = async (
  tabName: string
): Promise<void> => {
  // first decide which type of app the test user is in, Standard or Console
  const appLauncherRoot = await utam.load(AppLauncher);

  // if user is in Console app view
  if (await appLauncherRoot.isInConsoleApp()) {
    await openConsoleAppTabHome(tabName);
  }
  // if user is in Standard app view
  else {
    await openStandardAppTabHome(tabName);
  }

  await browser.pause(5000);
};

export const gotoRecordPageById = async (recordId: string): Promise<void> => {
  const domDocument = utam.getCurrentDocument();
  const url = await domDocument.getUrl();
  const origin = new URL(url).origin;
  const recordPageUrl = `${origin}/${recordId}`;

  await browser.navigateTo(recordPageUrl);
  await browser.pause(5000);
};
