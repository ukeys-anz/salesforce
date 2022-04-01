import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Tabset from "./../pageObjects/tabset";

async function _utam_get_tabset(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-tabset`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class Tabset2 extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_tabset(driver, root);
    element = new _Tabset(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
