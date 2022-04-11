"use strict";

var core = require("@utam/core");
var _Input = require("./../pageObjects/input");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Input__default = /*#__PURE__*/ _interopDefaultLegacy(_Input);

async function _utam_get_input(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-input`);
  _element = new core.ShadowRoot(driver, _element);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

class RecordLayoutBaseInput extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_input(driver, root);
    if (!element) {
      return null;
    }
    element = new _Input__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = RecordLayoutBaseInput;
