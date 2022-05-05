"use strict";

var core = require("@utam/core");
var _AppNavBar = require("./../pageObjects/appNavBar");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _AppNavBar__default = /*#__PURE__*/ _interopDefaultLegacy(_AppNavBar);

async function _utam_get_appLauncherHeader(driver, root) {
  let _element = root;
  const _locator = core.By.css(`one-app-launcher-header`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_appLauncherButton(driver, root) {
  let _element = await _utam_get_appLauncherHeader(driver, root);
  const _locator = core.By.css(`button`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_appNavBar(driver, root) {
  let _element = root;
  const _locator = core.By.css(`one-app-nav-bar`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class AppNav extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getAppLauncherHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_appLauncherHeader(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getAppLauncherButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_appLauncherButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getAppNavBar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_appNavBar(driver, root);
    element = new _AppNavBar__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async expandAppLauncher() {
    const _statement0 = await this.__getAppLauncherButton();
    await _statement0.click();
  }
}

module.exports = AppNav;
