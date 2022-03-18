import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ActionsContainer from "./../pageObjects/actionsContainer";

async function _utam_get_picker(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forceListViewPicker`);
  return _element.findElement(_locator);
}

async function _utam_get_selected(driver, root) {
  let _element = await _utam_get_picker(driver, root);
  const _locator = _By.css(`.selectedListView`);
  return _element.findElement(_locator);
}

async function _utam_get_actions(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forceActionsContainer`);
  return _element.findElement(_locator);
}

export default class ListViewManagerHeader extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getPicker() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_picker(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getSelected() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_selected(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getActions() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_actions(driver, root);
    element = new _ActionsContainer(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getSelectedListViewName() {
    const _statement0 = await this.__getSelected();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async waitForAction(labelText) {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.getActions();
      const _result1 = await _statement0.getActionLink(labelText);
      return _result1;
    });
    return _result0;
  }
}
