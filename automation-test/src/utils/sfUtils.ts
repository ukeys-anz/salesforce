export default class SfPageUtils {
  static closeAllTabsMain = async () => {
    const closableItems = await $$(
      "//ul[contains(@class,'tabBarItems')]//button[contains(@title,'Close')]"
    );

    await closableItems.forEach((element) => {
      element.click();
      browser.pause(2000);
    });
  };
}
