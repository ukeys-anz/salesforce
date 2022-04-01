"use strict";

var core = require("@utam/core");
var _Picklist = require("./../pageObjects/picklist");
var _Button = require("./../pageObjects/button");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Picklist__default = /*#__PURE__*/ _interopDefaultLegacy(_Picklist);
var _Button__default = /*#__PURE__*/ _interopDefaultLegacy(_Button);

async function _utam_get_picklist(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-picklist`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_editDependencyPanel(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-button`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class FormPicklist extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getPicklist() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_picklist(driver, root);
    element = new _Picklist__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getEditDependencyPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_editDependencyPanel(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = FormPicklist;
