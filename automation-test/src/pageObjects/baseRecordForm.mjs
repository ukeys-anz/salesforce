import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcRecordLayout from "./../pageObjects/lwcRecordLayout";
import _FormFooter from "./../pageObjects/formFooter";

async function _utam_get_recordLayoutContainer(driver, root) {
  let _element = root;
  const _locator = _By.css(`.record-layout-container`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_recordLayout(driver, root) {
  let _element = await _utam_get_recordLayoutContainer(driver, root);
  const _locator = _By.css(`records-lwc-record-layout`);
  return _element.findElement(_locator);
}

async function _utam_get_footer(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-form-footer`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class BaseRecordForm extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __beforeLoad__() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.containsElement(
        _By.css(`.record-layout-container`),
        true
      );
      return _result0;
    });
    return _result0;
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getRecordLayoutContainer() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_recordLayoutContainer(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getRecordLayout() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_recordLayout(driver, root);
    element = new _LwcRecordLayout(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getFooter() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_footer(driver, root);
    element = new _FormFooter(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async clickFooterButton(titleString) {
    await this.waitFor(async () => {
      const _result0 = await this.getFooter();
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement1 = await this.getFooter();
    const _statement2 = await _statement1.getActionsRibbon();
    const _statement3 = await _statement2.waitForRenderedAction(titleString);
    await _statement3.clickButton();
  }

  async waitForLoad() {
    await this.waitFor(async () => {
      const _statement0 = await this.__getRecordLayoutContainer();
      const _result0 = await _statement0.containsElement(
        _By.css(`records-lwc-record-layout`)
      );
      return _result0;
    });
    return this;
  }
}
