"use strict";

var core = require("@utam/core");
var _RecordCreationFormPicklistOption = require("./../pageObjects/recordCreationFormPicklistOption");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _RecordCreationFormPicklistOption__default =
  /*#__PURE__*/ _interopDefaultLegacy(_RecordCreationFormPicklistOption);

async function _utam_filter_optionByTitle(element, optionTitle) {
  const result = await element.getOptionTitle();
  return result === optionTitle;
}

async function _utam_get_optionByIndex(driver, root, ptionIndex) {
  let _element = root;
  const _locator = core.By.css(
    `li[class='uiMenuItem uiRadioMenuItem']:nth-of-type(${ptionIndex})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_optionByTitles(driver, root) {
  let _element = root;
  const _locator = core.By.css(`li`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElements(_locator);
}

class RecordCreationFormPicklist extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getOptionByIndex(ptionIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_optionByIndex(driver, root, ptionIndex);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getOptionByTitle(optionTitle) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_optionByTitles(driver, root);
    if (!elements) {
      return null;
    }
    elements = elements.map(function _createElement(element) {
      return new _RecordCreationFormPicklistOption__default[
        "default"
      ](driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_optionByTitle(el, optionTitle))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }

  async selectOptionByIndex(ptionIndex) {
    await this.waitFor(async () => {
      const _result0 = await this.getOptionByIndex(ptionIndex);
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement1 = await this.getOptionByIndex(ptionIndex);
    await _statement1.click();
  }
}

module.exports = RecordCreationFormPicklist;
