"use strict";

var core = require("@utam/core");
var _GroupedCombobox = require("./../pageObjects/groupedCombobox");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _GroupedCombobox__default =
  /*#__PURE__*/ _interopDefaultLegacy(_GroupedCombobox);

async function _utam_get_groupedCombobox(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-grouped-combobox`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LookupDesktop extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getGroupedCombobox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_groupedCombobox(driver, root);
    element = new _GroupedCombobox__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = LookupDesktop;
