"use strict";

var core = require("@utam/core");
var _CompletedQARelatedListItem = require("./../pageObjects/completedQARelatedListItem");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _CompletedQARelatedListItem__default = /*#__PURE__*/ _interopDefaultLegacy(
  _CompletedQARelatedListItem
);

async function _utam_filter_qualityAssessmentByNumber(element, qaNumber) {
  const result = await element.getNumber();
  return result.includes(qaNumber);
}

async function _utam_get_qaList(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.uiAbstractList .listContent ul`);
  return _element.findElement(_locator);
}

async function _utam_get_qualityAssessmentByNumbers(driver, root) {
  let _element = await _utam_get_qaList(driver, root);
  const _locator = core.By.css(`.forceListRecord`);
  return _element.findElements(_locator);
}

class CompletedQARelatedList extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getQaList() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_qaList(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getQualityAssessmentByNumber(qaNumber) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_qualityAssessmentByNumbers(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _CompletedQARelatedListItem__default[
        "default"
      ](driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_qualityAssessmentByNumber(el, qaNumber))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }
}

module.exports = CompletedQARelatedList;
