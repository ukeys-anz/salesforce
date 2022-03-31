"use strict";

var core = require("@utam/core");
var _LwcDetailPanel = require("./../pageObjects/lwcDetailPanel");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcDetailPanel__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LwcDetailPanel);

async function _utam_get_detailPanel(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-lwc-detail-panel`);
  return _element.findElement(_locator);
}

class Tab2 extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getDetailPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_detailPanel(driver, root);
    element = new _LwcDetailPanel__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = Tab2;
