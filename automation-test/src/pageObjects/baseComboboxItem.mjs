import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_itemByLabel(driver, root, itemLabel) {
  let _element = root;
  const _locator = _By.css(`span[title='${itemLabel}']`);
  _element = new _ShadowRoot(driver, _element);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

export default class BaseComboboxItem extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    return new ClickableUtamElement(driver, root);
  }

  async getItemByLabel(itemLabel) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_itemByLabel(driver, root, itemLabel);
    if (!element) {
      return null;
    }
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getItemValue() {
    const _statement0 = await this.__getRoot();
    const _result0 = await _statement0.getAttribute('"data-value"');
    return _result0;
  }

  async clickItem() {
    const _statement0 = await this.__getRoot();
    await _statement0.click();
  }
}
