"use strict";

var core = require("@utam/core");
var _Card = require("./../pageObjects/card");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Card__default = /*#__PURE__*/ _interopDefaultLegacy(_Card);

async function _utam_get_lightningCard(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-card`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class Hello extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLightningCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lightningCard(driver, root);
    element = new _Card__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getText() {
    const _statement0 = await this.__getLightningCard();
    const _result0 = await _statement0.getBodyText();
    return _result0;
  }
}

module.exports = Hello;
