import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _AppNavBar from "./../pageObjects/appNavBar";

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

  async getAppNavBar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_appNavBar(driver, root);
    element = new _AppNavBar(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
