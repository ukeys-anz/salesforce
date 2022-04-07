import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcFinancialGoalsPersonAccountGoalDetails from "./../pageObjects/lwcFinancialGoalsPersonAccountGoalDetails";

async function _utam_get_lightningCard(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-card .slds-card__body .slds-grid`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_goalss(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = _By.css(`[data-test-id='goal']`);
  return _element.findElements(_locator);
}

export default class LwcFinancialGoalsPersonAccount extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLightningCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lightningCard(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getGoals() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_goalss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _LwcFinancialGoalsPersonAccountGoalDetails(driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }
}
