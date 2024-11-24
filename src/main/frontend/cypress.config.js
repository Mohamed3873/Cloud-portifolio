const { defineConfig } = require('cypress');

module.exports = defineConfig({
    e2e: {
        setupNodeEvents(on, config) {
            // implement node event listeners here
        },
        baseUrl: 'http://34.78.241.203/',
        specPattern: 'cypress/e2e/**/*.cy.js',
        supportFile: false, // Disable the support file
    },
});
