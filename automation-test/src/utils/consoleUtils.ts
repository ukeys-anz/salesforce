import ConsoleAppNavigation from "pageObjects/consoleAppNavigation";
import AppLauncher from "pageObjects/appLauncher";

export const navigateToConsoleAppAndTab = async (
  appName: string,
  tabName: string
): Promise<void> => {
  const appLauncherRoot = await utam.load(AppLauncher);

  if (!(await appLauncherRoot.isCurrentApp(appName))) {
    // redirect user to console app
    await appLauncherRoot.redirectToApp(appName);
    await browser.pause(2000);
  }

  await closeConsoleNavMainTabs();
  await browser.pause(1000);

  const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);

  if (!(await consoleAppNavigationRoot.isCurrentTab(tabName))) {
    // redirect user to tab
    await consoleAppNavigationRoot.redirectToTab(tabName);
    await browser.pause(1000);
  } else {
    // click to redirect to current tab home
    await consoleAppNavigationRoot.redirectToCurrentTabHome();
  }
};

export const closeConsoleNavMainTabs = async (): Promise<void> => {
  const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);
  const tabBarItems = await consoleAppNavigationRoot.getTabBarItems();

  if (tabBarItems && tabBarItems.length > 0) {
    tabBarItems.forEach(async (item) => {
      await item.closeTab();
    });
  }
};
