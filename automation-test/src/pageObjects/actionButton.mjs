import {
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

export default class ActionButton extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    return new ClickableUtamElement(driver, root);
  }

  async getLabel() {
    const _statement0 = await this.__getRoot();
    const _result0 = await _statement0.getTitle();
    return _result0;
  }

  async click() {
    const _statement0 = await this.__getRoot();
    await _statement0.click();
  }
}
