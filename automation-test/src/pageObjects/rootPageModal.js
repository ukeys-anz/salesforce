"use strict";

var core = require("@utam/core");

async function _utam_get_modal(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.uiContainerManager`);
  return _element.findElement(_locator);
}

async function _utam_get_deleteButton(driver, root) {
  let _element = await _utam_get_modal(driver, root);
  const _locator = core.By.css(`[title='Delete']`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_modalDetail(driver, root) {
  let _element = await _utam_get_modal(driver, root);
  const _locator = core.By.css(`.detail`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

class RootPageModal extends core.UtamBaseRootPageObject {
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

  async __getModal() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_modal(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getDeleteButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_deleteButton(driver, root);
    if (!element) {
      return null;
    }
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getModalDetail() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_modalDetail(driver, root);
    if (!element) {
      return null;
    }
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async userHasNoPermissionToDeleteChatterPost() {
    const _statement0 = await this.getDeleteButton();
    if (_statement0 === null) {
      return null;
    }
    await _statement0.click();
    await this.waitFor(async () => {
      const _statement0 = await this.getModalDetail();
      if (_statement0 === null) {
        return null;
      }
      const _result0 = await _statement0.isVisible();
      return _result0;
    });
    const _statement2 = await this.getModalDetail();
    if (_statement2 === null) {
      return null;
    }
    const _result2 = await _statement2.getText();
    const _matcher2 =
      _result2 === "You do not have permission to delete this comment";
    return _matcher2;
  }
}

module.exports = RootPageModal;
