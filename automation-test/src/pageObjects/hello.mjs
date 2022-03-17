import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Card from "./../pageObjects/card";

async function _utam_get_lightningCard(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-card`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class Hello extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLightningCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lightningCard(driver, root);
    element = new _Card(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getText() {
    const _statement0 = await this.__getLightningCard();
    const _result0 = await _statement0.getBodyText();
    return _result0;
  }
}
