import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_targetValue(driver, root) {
  let _element = root;
  const _locator = _By.css(`[data-test-id='target-value']`);
  return _element.findElement(_locator);
}

async function _utam_get_totalSaved(driver, root) {
  let _element = root;
  const _locator = _By.css(`[data-test-id='total-saved']`);
  return _element.findElement(_locator);
}

export default class LwcFinancialGoalsDetails extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getTargetValue() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_targetValue(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getTotalSaved() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_totalSaved(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }
}
