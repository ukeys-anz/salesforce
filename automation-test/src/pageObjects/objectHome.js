"use strict";

var core = require("@utam/core");

async function _utam_get_listViewPicker(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forceListViewPicker`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewSelector(driver, root) {
  let _element = await _utam_get_listViewPicker(driver, root);
  const _locator = core.By.css(`[title='Select a List View']`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewPickerPanel(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.listViewPickerPanel`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewSearchBar(driver, root) {
  let _element = await _utam_get_listViewPickerPanel(driver, root);
  const _locator = core.By.css(`input`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewList(driver, root) {
  let _element = await _utam_get_listViewPickerPanel(driver, root);
  const _locator = core.By.css(`[role='listbox']`);
  return _element.findElement(_locator);
}

async function _utam_get_listView(driver, root) {
  let _element = await _utam_get_listViewList(driver, root);
  const _locator = core.By.css(`a`);
  return _element.findElement(_locator);
}

class ObjectHome extends core.UtamBaseRootPageObject {
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

  async __getListViewPicker() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_listViewPicker(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getListViewSelector() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_listViewSelector(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getListViewPickerPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_listViewPickerPanel(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getListViewSearchBar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableEditableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement,
      core.EditableUtamElement
    );
    let element = await _utam_get_listViewSearchBar(driver, root);
    element = new ClickableEditableUtamElement(driver, element);
    return element;
  }

  async __getListViewList() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_listViewList(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getListView() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_listView(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async openListView(listViewName) {
    const _statement0 = await this.__getListViewSelector();
    await _statement0.click();
    const _statement1 = await this.__getListViewSearchBar();
    await _statement1.clearAndType(listViewName);
    const _statement2 = await this.__getListView();
    await _statement2.click();
  }
}

module.exports = ObjectHome;
