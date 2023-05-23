import { createElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CreateCaseButton from 'c/createCaseButton';

describe('c-create-case-button', () => {
    it('should invoke the navigation mixin', () => {
        // Create a mock instance of the NavigationMixin
        const MockNavigationMixin = Base => class extends Base {
            [NavigationMixin.Navigate](nav) {
                // Verify the expected navigation parameters
                expect(nav).toEqual({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Case',
                        actionName: 'new',
                    },
                });
            }
        };

        // Extend the navigateToRecordAction class with the mock NavigationMixin
        const MockComponent = MockNavigationMixin(CreateCaseButton);

        // Create an instance of the MockComponent
        const element = createElement('c-create-case-button', {
            is: MockComponent,
        });

        // Invoke the 'invoke' method
        element.invoke();
    });
});