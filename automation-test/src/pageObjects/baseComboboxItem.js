"use strict";

var core = require("@utam/core");

async function _utam_get_itemByLabel(driver, root, itemLabel) {
  let _element = root;
  const _locator = core.By.css(`span[title='${itemLabel}']`);
  _element = new core.ShadowRoot(driver, _element);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

class BaseComboboxItem extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    return new ClickableUtamElement(driver, root);
  }

  async getItemByLabel(itemLabel) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
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

module.exports = BaseComboboxItem;
