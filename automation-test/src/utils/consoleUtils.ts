import ConsoleAppNavigation from "pageObjects/consoleAppNavigation";
import AppLauncher from "pageObjects/appLauncher";

export const navigateToConsoleAppAndObjectHome = async (
  appName: string,
  objectTabName: string
): Promise<void> => {
  // redirect user to console app
  const appLauncherRoot = await utam.load(AppLauncher);
  await appLauncherRoot.redirectToApp(appName);
  await browser.pause(2000);

  await closeConsoleNavMainTabs();
  await browser.pause(1000);

  // redirect user to Object tab
  const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);
  await consoleAppNavigationRoot.redirectToTab(objectTabName);
  await browser.pause(1000);
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
