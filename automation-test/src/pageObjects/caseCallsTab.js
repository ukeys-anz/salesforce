"use strict";

var core = require("@utam/core");
var _LwcCaseLogACall = require("./../pageObjects/lwcCaseLogACall");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcCaseLogACall__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LwcCaseLogACall);

async function _utam_get_caseLogACall(driver, root) {
  let _element = root;
  const _locator = core.By.css(`c-case-log-a-call`);
  return _element.findElement(_locator);
}

class CaseCallsTab extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getCaseLogACall() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_caseLogACall(driver, root);
    element = new _LwcCaseLogACall__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = CaseCallsTab;
