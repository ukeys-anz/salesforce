import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Input from "./../pageObjects/input";

async function _utam_get_input(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-input`);
  _element = new _ShadowRoot(driver, _element);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

export default class RecordLayoutBaseInput extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_input(driver, root);
    if (!element) {
      return null;
    }
    element = new _Input(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
