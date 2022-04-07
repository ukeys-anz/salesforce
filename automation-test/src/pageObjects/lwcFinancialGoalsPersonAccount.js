"use strict";

var core = require("@utam/core");
var _LwcFinancialGoalsPersonAccountGoalDetails = require("./../pageObjects/lwcFinancialGoalsPersonAccountGoalDetails");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcFinancialGoalsPersonAccountGoalDetails__default =
  /*#__PURE__*/ _interopDefaultLegacy(
    _LwcFinancialGoalsPersonAccountGoalDetails
  );

async function _utam_get_lightningCard(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-card .slds-card__body .slds-grid`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_goalss(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = core.By.css(`[data-test-id='goal']`);
  return _element.findElements(_locator);
}

class LwcFinancialGoalsPersonAccount extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLightningCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_lightningCard(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getGoals() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_goalss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _LwcFinancialGoalsPersonAccountGoalDetails__default[
        "default"
      ](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }
}

module.exports = LwcFinancialGoalsPersonAccount;
