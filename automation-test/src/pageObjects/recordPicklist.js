"use strict";

var core = require("@utam/core");
var _FormPicklist = require("./../pageObjects/formPicklist");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _FormPicklist__default = /*#__PURE__*/ _interopDefaultLegacy(_FormPicklist);

async function _utam_get_formPicklist(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-form-picklist`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class RecordPicklist extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getFormPicklist() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_formPicklist(driver, root);
    element = new _FormPicklist__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getBasePicklist() {
    const _statement0 = await this.getFormPicklist();
    const _result1 = await _statement0.getPicklist();
    return _result1;
  }
}

module.exports = RecordPicklist;
