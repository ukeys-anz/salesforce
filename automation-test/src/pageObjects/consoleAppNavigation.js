"use strict";

var core = require("@utam/core");
var _ConsoleTabBarItem = require("./../pageObjects/consoleTabBarItem");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ConsoleTabBarItem__default =
  /*#__PURE__*/ _interopDefaultLegacy(_ConsoleTabBarItem);

async function _utam_get_navMenu(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[title='Show Navigation Menu']`);
  return _element.findElement(_locator);
}

async function _utam_get_navMenuItem(driver, root, menuItem) {
  let _element = root;
  const _locator = core.By.css(`li a[data-label='${menuItem}']`);
  return _element.findElement(_locator);
}

async function _utam_get_tabBarItemss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.tabsetHeader ul.tabBarItems > li.tabItem`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElements(_locator);
}

async function _utam_get_currentTab(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div[class*='selectedListItem'] a`);
  return _element.findElement(_locator);
}

class ConsoleAppNavigation extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getNavMenu() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_navMenu(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getNavMenuItem(menuItem) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_navMenuItem(driver, root, menuItem);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getTabBarItems() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_tabBarItemss(driver, root);
    if (!elements) {
      return null;
    }
    elements = elements.map(function _createElement(element) {
      return new _ConsoleTabBarItem__default["default"](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getCurrentTab() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_currentTab(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async redirectToTab(menuItem) {
    const _statement0 = await this.__getNavMenu();
    await _statement0.click();
    await this.waitFor(async () => {
      const _result0 = await this.__getNavMenuItem(menuItem);
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement2 = await this.__getNavMenuItem(menuItem);
    await _statement2.click();
  }

  async isCurrentTab(tabName) {
    const _statement0 = await this.getCurrentTab();
    const _result0 = await _statement0.getTitle();
    const _matcher0 = _result0 === tabName;
    return _matcher0;
  }

  async redirectToCurrentTabHome() {
    const _statement0 = await this.getCurrentTab();
    await _statement0.click();
  }
}

module.exports = ConsoleAppNavigation;
