"use strict";

var core = require("@utam/core");
var _BaseCombobox = require("./../pageObjects/baseCombobox");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _BaseCombobox__default = /*#__PURE__*/ _interopDefaultLegacy(_BaseCombobox);

async function _utam_get_baseCombobox(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-base-combobox`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class GroupedCombobox extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getBaseCombobox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_baseCombobox(driver, root);
    element = new _BaseCombobox__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = GroupedCombobox;
