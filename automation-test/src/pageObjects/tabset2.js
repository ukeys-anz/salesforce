"use strict";

var core = require("@utam/core");
var _Tabset = require("./../pageObjects/tabset");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Tabset__default = /*#__PURE__*/ _interopDefaultLegacy(_Tabset);

async function _utam_get_tabset(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-tabset`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class Tabset2 extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_tabset(driver, root);
    element = new _Tabset__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = Tabset2;
