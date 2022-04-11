"use strict";

var core = require("@utam/core");
var _ActionsContainer = require("./../pageObjects/actionsContainer");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ActionsContainer__default = /*#__PURE__*/ _interopDefaultLegacy(
  _ActionsContainer
);

async function _utam_get_picker(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forceListViewPicker`);
  return _element.findElement(_locator);
}

async function _utam_get_selected(driver, root) {
  let _element = await _utam_get_picker(driver, root);
  const _locator = core.By.css(`.selectedListView`);
  return _element.findElement(_locator);
}

async function _utam_get_actions(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forceActionsContainer`);
  return _element.findElement(_locator);
}

class ListViewManagerHeader extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getPicker() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_picker(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getSelected() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_selected(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getActions() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_actions(driver, root);
    element = new _ActionsContainer__default["default"](driver, element);
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

module.exports = ListViewManagerHeader;
