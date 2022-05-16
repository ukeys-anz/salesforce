import ConsoleAppNavigation from "pageObjects/consoleAppNavigation";
import AppLauncher from "pageObjects/appLauncher";
import HomePage from "pageObjects/homePage";
import AppsDefinition from "constants/appsDefinition";

export const closeConsoleNavMainTabs = async (): Promise<void> => {
  const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);
  const tabBarItems = await consoleAppNavigationRoot.getTabBarItems();

  if (tabBarItems && tabBarItems.length > 0) {
    tabBarItems.forEach(async (item) => {
      await item.closeTab();
    });
  }
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
        // redirect user to console app
        await appLauncherRoot.redirectToApp(appName);
        await browser.pause(2000);
      }

      // user is in redirected Console app view now
      await closeConsoleNavMainTabs();
      await browser.pause(1000);

      const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);

      if (!(await consoleAppNavigationRoot.isCurrentTab(tabName))) {
        // redirect user to tab
        await consoleAppNavigationRoot.redirectToTab(tabName);
      } else {
        // click to redirect to current tab home
        await consoleAppNavigationRoot.redirectToCurrentTabHome();
      }
    } else {
      // if redirectTo app is Standard App
      // redirect user to the app
      await appLauncherRoot.redirectToApp(appName);
      await browser.pause(2000);

      // user is in Standard app view now
      const homePageRoot = await utam.load(HomePage);
      const navigationBar = await homePageRoot.getNavigationBar();
      const appNavBar = await navigationBar.getAppNavBar();
      const navItem = await appNavBar.getNavItem(tabName);

      if (tabName === "Home") {
        tabName = "home";
      }
      await navItem.clickAndWaitForUrl(tabName);
    }
  } // if user is in Standard app view
  else {
    // in Standard app, open App Launcher
    const homePageRoot = await utam.load(HomePage);
    const navBar = await homePageRoot.getNavigationBar();
    await navBar.expandAppLauncher();
    await browser.pause(1000);

    // search redirectTo app name and click and redirect
    await appLauncherRoot.searchAppLwc(appName);
    await browser.pause(1000);
    await appLauncherRoot.selectAppLwcAndRedirect();
    await browser.pause(2000);

    if (redirectToAppType === "Console") {
      // user is in redirected Console app view now
      await closeConsoleNavMainTabs();
      await browser.pause(1000);

      const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);

      if (!(await consoleAppNavigationRoot.isCurrentTab(tabName))) {
        // redirect user to tab
        await consoleAppNavigationRoot.redirectToTab(tabName);
      } else {
        // click to redirect to current tab home
        await consoleAppNavigationRoot.redirectToCurrentTabHome();
      }
    } else {
      // user is in Standard app view now
      const homePageRoot = await utam.load(HomePage);
      const navigationBar = await homePageRoot.getNavigationBar();
      const appNavBar = await navigationBar.getAppNavBar();
      const navItem = await appNavBar.getNavItem(tabName);

      if (tabName === "Home") {
        tabName = "home";
      }
      await navItem.clickAndWaitForUrl(tabName);
    }
  }

  await browser.pause(4000);
};
