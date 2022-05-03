"use strict";

var core = require("@utam/core");
var _LwcFinancialAccountParent = require("./../pageObjects/lwcFinancialAccountParent");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcFinancialAccountParent__default = /*#__PURE__*/ _interopDefaultLegacy(
  _LwcFinancialAccountParent
);

async function _utam_get_financialAccountParent(driver, root) {
  let _element = root;
  const _locator = core.By.css(`c-financial-account-parent`);
  return _element.findElement(_locator);
}

class FinancialAccountTab extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getFinancialAccountParent() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_financialAccountParent(driver, root);
    element = new _LwcFinancialAccountParent__default["default"](
      driver,
      element
    );
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = FinancialAccountTab;
