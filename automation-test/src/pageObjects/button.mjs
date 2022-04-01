import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_button(driver, root) {
  let _element = root;
  const _locator = _By.css(`button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class Button extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_button(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async click() {
    const _statement0 = await this.__getButton();
    await _statement0.click();
  }

  async getButtonName() {
    const _statement0 = await this.__getButton();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getClassAttr() {
    const _statement0 = await this.__getRoot();
    const _result0 = await _statement0.getAttribute('"class"');
    return _result0;
  }

  async isDisabled() {
    const _statement0 = await this.__getButton();
    const _result0 = await _statement0.getAttribute('"disabled"');
    return _result0;
  }
}
