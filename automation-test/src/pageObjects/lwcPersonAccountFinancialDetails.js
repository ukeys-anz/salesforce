"use strict";

var core = require("@utam/core");
var _LwcFinancialGoalsPersonAccount = require("./../pageObjects/lwcFinancialGoalsPersonAccount");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcFinancialGoalsPersonAccount__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LwcFinancialGoalsPersonAccount);

async function _utam_get_financialGoals(driver, root) {
  let _element = root;
  const _locator = core.By.css(`c-financial-goals-person-account`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LwcPersonAccountFinancialDetails extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getFinancialGoals() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_financialGoals(driver, root);
    element = new _LwcFinancialGoalsPersonAccount__default["default"](
      driver,
      element
    );
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = LwcPersonAccountFinancialDetails;
