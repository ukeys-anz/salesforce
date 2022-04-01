"use strict";

var core = require("@utam/core");
var _Combobox = require("./../pageObjects/combobox");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Combobox__default = /*#__PURE__*/ _interopDefaultLegacy(_Combobox);

async function _utam_get_comboBox(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-combobox`);
  _element = new core.ShadowRoot(driver, _element);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

class Picklist extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getComboBox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_comboBox(driver, root);
    if (!element) {
      return null;
    }
    element = new _Combobox__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getBaseCombobox() {
    const _statement0 = await this.getComboBox();
    const _result1 = await _statement0.getBase();
    return _result1;
  }
}

module.exports = Picklist;
