import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Button from "./../pageObjects/button";

async function _utam_get_lightningButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-button`);
  return _element.findElement(_locator);
}

export default class ExecutorLwcHeadless extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getLightningButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lightningButton(driver, root);
    element = new _Button(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
