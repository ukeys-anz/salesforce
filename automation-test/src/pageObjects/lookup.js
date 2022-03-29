"use strict";

var core = require("@utam/core");
var _LookupDesktop = require("./../pageObjects/lookupDesktop");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LookupDesktop__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LookupDesktop);

async function _utam_get_lookupDesktop(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-lookup-desktop`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class Lookup extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getLookupDesktop() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lookupDesktop(driver, root);
    element = new _LookupDesktop__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getBaseCombobox() {
    const _statement0 = await this.getLookupDesktop();
    const _statement1 = await _statement0.getGroupedCombobox();
    const _result2 = await _statement1.getBaseCombobox();
    return _result2;
  }
}

module.exports = Lookup;
