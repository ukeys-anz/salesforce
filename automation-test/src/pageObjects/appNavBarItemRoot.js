"use strict";

var core = require("@utam/core");

async function _utam_get_itemLink(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class AppNavBarItemRoot extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    return new ClickableUtamElement(driver, root);
  }

  async getItemLink() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_itemLink(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getItemText() {
    const _statement0 = await this.getItemLink();
    const _result0 = await _statement0.getTitle();
    return _result0;
  }

  async clickAndWaitForUrl(url) {
    const _statement0 = await this.getRoot();
    await _statement0.click();
    const _result1 = await this.waitFor(async () => {
      const _statement0 = await this.getDocument();
      const _result0 = await _statement0.getUrl();
      const _matcher0 = _result0.includes(url);
      return _matcher0;
    });
    return _result1;
  }
}

module.exports = AppNavBarItemRoot;
