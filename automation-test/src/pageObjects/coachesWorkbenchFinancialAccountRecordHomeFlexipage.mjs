import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _CoachesWorkbenchRecordHomeTemplateDesktop2 from "./../pageObjects/coachesWorkbenchRecordHomeTemplateDesktop2";
import _LwcFinancialAccountParent from "./../pageObjects/lwcFinancialAccountParent";
import _RecordPageDecorator from "./../pageObjects/recordPageDecorator";

async function _utam_get_adgRollup(driver, root) {
  let _element = root;
  const _locator = _By.css(`.adg-rollup-wrapped`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_flexipageModule(driver, root) {
  let _element = await _utam_get_adgRollup(driver, root);
  const _locator = _By.css(`.forcegenerated-flexipage-module`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_decorator(driver, root) {
  let _element = await _utam_get_flexipageModule(driver, root);
  const _locator = _By.css(`record_flexipage-record-page-decorator`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class CoachesWorkbenchFinancialAccountRecordHomeFlexipage extends _UtamBaseRootPageObject {
  constructor(
    driver,
    element,
    locator = _By.css(
      `section[class='tabContent active oneConsoleTab'] section[class='tabContent active oneConsoleTab'] one-record-home-flexipage2`
    )
  ) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getAdgRollup() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_adgRollup(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFlexipageModule() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_flexipageModule(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getDecorator() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_decorator(driver, root);
    element = new _RecordPageDecorator(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getFinancialAccountRecordPage() {
    const _statement0 = await this.getDecorator();
    const _statement1 = await _statement0.getEventBroker();
    const _result2 = await _statement1.getGeneratedTemplate(
      _CoachesWorkbenchRecordHomeTemplateDesktop2
    );
    return _result2;
  }

  async getFinancialAccount() {
    const _statement0 = await this.getFinancialAccountRecordPage();
    const _statement1 = await _statement0.getMainRegionTabset();
    const _statement2 = await _statement1.getDetailComponent();
    const _result3 = await _statement2.getContent(_LwcFinancialAccountParent);
    return _result3;
  }
}
