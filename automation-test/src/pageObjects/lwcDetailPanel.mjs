import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _BaseRecordForm from "./../pageObjects/baseRecordForm";

async function _utam_get_baseRecordForm(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-base-record-form`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class LwcDetailPanel extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getBaseRecordForm() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_baseRecordForm(driver, root);
    element = new _BaseRecordForm(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
