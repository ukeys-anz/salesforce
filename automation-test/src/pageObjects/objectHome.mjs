import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  EditableUtamElement as _EditableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

async function _utam_get_listViewPicker(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forceListViewPicker`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewSelector(driver, root) {
  let _element = await _utam_get_listViewPicker(driver, root);
  const _locator = _By.css(`[title='Select a List View']`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewPickerPanel(driver, root) {
  let _element = root;
  const _locator = _By.css(`.listViewPickerPanel`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewSearchBar(driver, root) {
  let _element = await _utam_get_listViewPickerPanel(driver, root);
  const _locator = _By.css(`input`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewList(driver, root) {
  let _element = await _utam_get_listViewPickerPanel(driver, root);
  const _locator = _By.css(`[role='listbox']`);
  return _element.findElement(_locator);
}

async function _utam_get_listView(driver, root) {
  let _element = await _utam_get_listViewList(driver, root);
  const _locator = _By.css(`a`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewss(driver, root) {
  let _element = await _utam_get_listViewList(driver, root);
  const _locator = _By.css(`a`);
  return _element.findElements(_locator);
}

export default class ObjectHome extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
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

  async __getListViewPicker() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_listViewPicker(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getListViewSelector() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_listViewSelector(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getListViewPickerPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_listViewPickerPanel(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getListViewSearchBar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableEditableUtamElement = _createUtamMixinCtor(
      _ClickableUtamElement,
      _EditableUtamElement
    );
    let element = await _utam_get_listViewSearchBar(driver, root);
    element = new ClickableEditableUtamElement(driver, element);
    return element;
  }

  async __getListViewList() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_listViewList(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getListView() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_listView(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getListViews() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let elements = await _utam_get_listViewss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    return elements;
  }

  async searchListView(listViewName) {
    const _statement0 = await this.__getListViewSelector();
    await _statement0.click();
    const _statement1 = await this.__getListViewSearchBar();
    await _statement1.clearAndType(listViewName);
    await _statement1.click();
  }

  async openListView() {
    const _statement0 = await this.__getListView();
    await _statement0.click();
  }
}
