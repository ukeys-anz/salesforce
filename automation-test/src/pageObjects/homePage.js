"use strict";

var core = require("@utam/core");
var _AppNav = require("./../pageObjects/appNav");
var _AppFlexipage = require("./../pageObjects/appFlexipage");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _AppNav__default = /*#__PURE__*/ _interopDefaultLegacy(_AppNav);
var _AppFlexipage__default = /*#__PURE__*/ _interopDefaultLegacy(_AppFlexipage);

async function _utam_get_navigationBar(driver, root) {
  let _element = root;
  const _locator = core.By.css(`one-appnav`);
  return _element.findElement(_locator);
}

async function _utam_get_activeFlexiPage(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.oneContent.active app_flexipage-lwc-app-flexipage`
  );
  return _element.findElement(_locator);
}

class HomePage extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getNavigationBar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_navigationBar(driver, root);
    element = new _AppNav__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getActiveFlexiPage() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_activeFlexiPage(driver, root);
    element = new _AppFlexipage__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getComponent() {
    const _statement0 = await this.getActiveFlexiPage();
    const _statement1 = await _statement0.waitForLoad();
    const _result2 = await _statement1.getFlexipageComponent2();
    return _result2;
  }
}

module.exports = HomePage;
