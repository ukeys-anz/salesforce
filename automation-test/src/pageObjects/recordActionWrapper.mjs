import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _ChangeRecordTypeFooter from "./../pageObjects/changeRecordTypeFooter";
import _ModalLwcDetailPanelWrapper from "./../pageObjects/modalLwcDetailPanelWrapper";

async function _utam_get_body(driver, root) {
  let _element = root;
  const _locator = _By.css(`.actionBody`);
  return _element.findElement(_locator);
}

async function _utam_get_detailsPanelContainer(driver, root) {
  let _element = await _utam_get_body(driver, root);
  const _locator = _By.css(`:scope > *:first-child`);
  return _element.findElement(_locator);
}

async function _utam_get_footer(driver, root) {
  let _element = root;
  const _locator = _By.css(`.inlineFooter`);
  return _element.findElement(_locator);
}

async function _utam_get_footerContent(driver, root) {
  let _element = await _utam_get_footer(driver, root);
  const _locator = _By.css(`:scope > *:first-child`);
  return _element.findElement(_locator);
}

export default class RecordActionWrapper extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`.oneRecordActionWrapper`)) {
    super(driver, element, locator);
  }

  async __beforeLoad__() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.getRoot();
      await _statement0.isPresent();
      const _result1 = await _statement0.containsElement(
        _By.css(`.actionBody`)
      );
      return _result1;
    });
    return _result0;
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_body(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getDetailsPanelContainer(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_detailsPanelContainer(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async __getFooter() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_footer(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getFooterContent(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_footerContent(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async waitForFooter() {
    const _result0 = await this.waitFor(async () => {
      const _result0 = await this.__getFooter();
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    return _result0;
  }

  async waitForChangeRecordFooter() {
    const _result0 = await this.waitFor(async () => {
      await this.__getFooter();
      const _result1 = await this.getFooterContent(_ChangeRecordTypeFooter);
      return _result1;
    });
    return _result0;
  }

  async getRecordForm() {
    const _statement0 = await this.waitFor(async () => {
      const _result0 = await this.getDetailsPanelContainer(
        _ModalLwcDetailPanelWrapper
      );
      return _result0;
    });
    const _statement1 = await _statement0.getLwcDetailPanel();
    const _statement2 = await _statement1.getBaseRecordForm();
    const _result3 = await _statement2.waitForLoad();
    return _result3;
  }
}
