"use strict";

var core = require("@utam/core");

async function _utam_get_modalManager(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.uiContainerManager`);
  return _element.findElement(_locator);
}

async function _utam_get_modalWrapper(driver, root) {
  let _element = await _utam_get_modalManager(driver, root);
  const _locator = core.By.css(`.active.lafPageHost .oneRecordActionWrapper`);
  return _element.findElement(_locator);
}

async function _utam_get_reasonForChangeEditField(driver, root) {
  let _element = await _utam_get_modalWrapper(driver, root);
  const _locator = core.By.css(
    `.forcePageBlockSection:nth-of-type(1) .forcePageBlockSectionRow:nth-of-type(2) .forcePageBlockItem:nth-of-type(1) textarea`
  );
  return _element.findElement(_locator);
}

async function _utam_get_saveButton(driver, root) {
  let _element = await _utam_get_modalManager(driver, root);
  const _locator = core.By.css(`.inlineFooter button[title='Save']`);
  return _element.findElement(_locator);
}

class KnowledgeEditAsDraftModal extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
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
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getModalManager() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_modalManager(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getModalWrapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_modalWrapper(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getReasonForChangeEditField() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableEditableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement,
      core.EditableUtamElement
    );
    let element = await _utam_get_reasonForChangeEditField(driver, root);
    element = new ClickableEditableUtamElement(driver, element);
    return element;
  }

  async getSaveButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_saveButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async saveDraft() {
    const _statement0 = await this.getSaveButton();
    await _statement0.click();
  }

  async editReasonForChangeEdit(reasonForChangeText) {
    const _statement0 = await this.__getReasonForChangeEditField();
    await _statement0.clearAndType(reasonForChangeText);
  }
}

module.exports = KnowledgeEditAsDraftModal;
