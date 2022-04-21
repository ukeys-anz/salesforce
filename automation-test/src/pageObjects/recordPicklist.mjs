import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _FormPicklist from "./../pageObjects/formPicklist";

async function _utam_get_formPicklist(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-form-picklist`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class RecordPicklist extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getFormPicklist() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_formPicklist(driver, root);
    element = new _FormPicklist(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getBasePicklist() {
    const _statement0 = await this.getFormPicklist();
    const _result1 = await _statement0.getPicklist();
    return _result1;
  }
}
