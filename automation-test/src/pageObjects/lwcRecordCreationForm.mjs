import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _BaseRecordForm from "./../pageObjects/baseRecordForm";

async function _utam_get_modalDetailPanelWrapper(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-modal-lwc-detail-panel-wrapper`);
  return _element.findElement(_locator);
}

async function _utam_get_modalDetailPanel(driver, root) {
  let _element = await _utam_get_modalDetailPanelWrapper(driver, root);
  const _locator = _By.css(`records-lwc-detail-panel`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_modalBaseRecordForm(driver, root) {
  let _element = await _utam_get_modalDetailPanel(driver, root);
  const _locator = _By.css(`records-base-record-form`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_relatedListDetailPanelWrapper(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-related-list-lwc-detail-panel-wrapper`);
  return _element.findElement(_locator);
}

async function _utam_get_relatedListDetailPanel(driver, root) {
  let _element = await _utam_get_relatedListDetailPanelWrapper(driver, root);
  const _locator = _By.css(`records-lwc-detail-panel`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_relatedListBaseRecordForm(driver, root) {
  let _element = await _utam_get_relatedListDetailPanel(driver, root);
  const _locator = _By.css(`records-base-record-form`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class LwcRecordCreationForm extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`.active.lafPageHost`)) {
    super(driver, element, locator);
  }

  async __beforeLoad__() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.isVisible();
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

  async __getModalDetailPanelWrapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_modalDetailPanelWrapper(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getModalDetailPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_modalDetailPanel(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getModalBaseRecordForm() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_modalBaseRecordForm(driver, root);
    element = new _BaseRecordForm(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getRelatedListDetailPanelWrapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_relatedListDetailPanelWrapper(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getRelatedListDetailPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_relatedListDetailPanel(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getRelatedListBaseRecordForm() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_relatedListBaseRecordForm(driver, root);
    element = new _BaseRecordForm(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
