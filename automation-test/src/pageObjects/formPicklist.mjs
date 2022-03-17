import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Picklist from "./../pageObjects/picklist";
import _Button from "./../pageObjects/button";

async function _utam_get_picklist(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-picklist`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_editDependencyPanel(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class FormPicklist extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getPicklist() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_picklist(driver, root);
    element = new _Picklist(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getEditDependencyPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_editDependencyPanel(driver, root);
    element = new _Button(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
