import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _AppNavBar from "./../pageObjects/appNavBar";

async function _utam_get_appLauncherHeader(driver, root) {
  let _element = root;
  const _locator = _By.css(`one-app-launcher-header`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_appLauncherButton(driver, root) {
  let _element = await _utam_get_appLauncherHeader(driver, root);
  const _locator = _By.css(`button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_appNavBar(driver, root) {
  let _element = root;
  const _locator = _By.css(`one-app-nav-bar`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class AppNav extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getAppLauncherHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_appLauncherHeader(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getAppLauncherButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_appLauncherButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getAppNavBar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_appNavBar(driver, root);
    element = new _AppNavBar(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async expandAppLauncher() {
    const _statement0 = await this.__getAppLauncherButton();
    await _statement0.click();
  }
}
