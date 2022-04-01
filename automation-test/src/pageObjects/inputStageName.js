"use strict";

var core = require("@utam/core");
var _RecordPicklist = require("./../pageObjects/recordPicklist");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _RecordPicklist__default =
  /*#__PURE__*/ _interopDefaultLegacy(_RecordPicklist);

async function _utam_get_recordPicklist(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-record-picklist`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class InputStageName extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getRecordPicklist() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_recordPicklist(driver, root);
    element = new _RecordPicklist__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = InputStageName;
