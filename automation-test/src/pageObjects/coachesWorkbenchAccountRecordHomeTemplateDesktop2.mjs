import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcPersonAccountFinancialDetails from "./../pageObjects/lwcPersonAccountFinancialDetails";
import _ChatterPanel from "./../pageObjects/chatterPanel";

async function _utam_get_financialDetails(driver, root) {
  let _element = root;
  const _locator = _By.css(`c-person-account-financial-details`);
  return _element.findElement(_locator);
}

async function _utam_get_chatterWrapper(driver, root) {
  let _element = root;
  const _locator = _By.css(
    `.right-col > slot > flexipage-component2:nth-of-type(3) flexipage-aura-wrapper`
  );
  return _element.findElement(_locator);
}

async function _utam_get_chatterPanel(driver, root) {
  let _element = await _utam_get_chatterWrapper(driver, root);
  const _locator = _By.css(`.forceChatterRecordFeedContainerDesktop`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class CoachesWorkbenchAccountRecordHomeTemplateDesktop2 extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getFinancialDetails() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_financialDetails(driver, root);
    element = new _LwcPersonAccountFinancialDetails(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getChatterWrapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_chatterWrapper(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getChatterPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_chatterPanel(driver, root);
    element = new _ChatterPanel(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
