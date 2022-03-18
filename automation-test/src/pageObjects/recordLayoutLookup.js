"use strict";

var core = require("@utam/core");
var _Lookup = require("./../pageObjects/lookup");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Lookup__default = /*#__PURE__*/ _interopDefaultLegacy(_Lookup);

async function _utam_get_lookup(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-lookup`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class RecordLayoutLookup extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getLookup() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lookup(driver, root);
    element = new _Lookup__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = RecordLayoutLookup;
