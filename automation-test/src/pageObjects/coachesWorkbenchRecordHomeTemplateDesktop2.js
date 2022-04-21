"use strict";

var core = require("@utam/core");
var _CoachesWorkbenchTabset2 = require("./../pageObjects/coachesWorkbenchTabset2");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _CoachesWorkbenchTabset2__default = /*#__PURE__*/ _interopDefaultLegacy(
  _CoachesWorkbenchTabset2
);

async function _utam_get_mainRegionTabset(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.row-main .region-main flexipage-tabset2:first-child`
  );
  return _element.findElement(_locator);
}

class CoachesWorkbenchRecordHomeTemplateDesktop2 extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getMainRegionTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_mainRegionTabset(driver, root);
    element = new _CoachesWorkbenchTabset2__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = CoachesWorkbenchRecordHomeTemplateDesktop2;
