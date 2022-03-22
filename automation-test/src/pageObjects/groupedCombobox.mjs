import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _BaseCombobox from "./../pageObjects/baseCombobox";

async function _utam_get_baseCombobox(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-base-combobox`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class GroupedCombobox extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getBaseCombobox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_baseCombobox(driver, root);
    element = new _BaseCombobox(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
