
describe('Frontend Items List Test', () => {
    it('Loads the page and fetches items', () => {
        // Visit the frontend
        cy.visit('http://34.78.241.203/'); // Replace with your actual frontend URL

        // Verify the page title
        cy.contains('Items from Database').should('be.visible');

        cy.intercept('GET', 'http://34.77.4.205:8080/data').as('fetchItems')
            .then((interception) => {
                console.log('Intercepted:', interception);
            });

        // Verify the Fetch Items button exists
        cy.get('button').contains('Fetch Items').should('be.visible').click();



        // Wait for fetch and verify table content
        cy.wait('@fetchItems',{ timeout: 40000 });
        cy.get('table tbody').within(() => {
            cy.contains('Item1').should('exist');
            cy.contains('1').should('exist');
            cy.contains('Item2').should('exist');
            cy.contains('2').should('exist');
        });
    });

    it('Handles fetch error gracefully', () => {
        // Visit the frontend
        cy.visit('http://34.78.241.203/');

        // Mock backend error
        cy.intercept('GET', 'http://34.77.4.205:8080/', {
            statusCode: 500,
        }).as('fetchError');

        // Trigger the fetch
        cy.get('button').contains('Fetch Items').click();

        // Verify console shows an error (replace with UI error message if needed)
        cy.on('window:alert', (str) => {
            expect(str).to.equal('Error fetching data:');
        });
    });
});
