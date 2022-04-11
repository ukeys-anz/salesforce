"use strict";

var core = require("@utam/core");
var _LwcRecordLayout = require("./../pageObjects/lwcRecordLayout");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcRecordLayout__default = /*#__PURE__*/ _interopDefaultLegacy(
  _LwcRecordLayout
);

async function _utam_get_recordLayout(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-lwc-record-layout`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LwcHighlightsPanel extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getRecordLayout() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_recordLayout(driver, root);
    element = new _LwcRecordLayout__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getActions() {
    const _statement0 = await this.waitFor(async () => {
      const _result0 = await this.getRecordLayout();
      return _result0;
    });
    const _statement1 = await _statement0.waitForHighlights2();
    const _result2 = await _statement1.getActionsRibbon();
    return _result2;
  }
}

module.exports = LwcHighlightsPanel;
