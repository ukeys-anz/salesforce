"use strict";

var core = require("@utam/core");

async function _utam_get_content(driver, root) {
  let _element = root;
  const _locator = core.By.css(`:scope *`);
  return _element.findElement(_locator);
}

class Component2 extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getContent(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_content(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }
}

module.exports = Component2;
