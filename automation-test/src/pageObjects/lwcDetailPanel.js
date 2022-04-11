"use strict";

var core = require("@utam/core");
var _BaseRecordForm = require("./../pageObjects/baseRecordForm");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _BaseRecordForm__default = /*#__PURE__*/ _interopDefaultLegacy(
  _BaseRecordForm
);

async function _utam_get_baseRecordForm(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-base-record-form`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LwcDetailPanel extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getBaseRecordForm() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_baseRecordForm(driver, root);
    element = new _BaseRecordForm__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = LwcDetailPanel;
