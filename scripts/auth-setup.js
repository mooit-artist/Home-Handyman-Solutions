#!/usr/bin/env node

/**
 * Quick Jobber Authentication Setup
 * This script helps set up authentication for Jobber API access
 */

const JobberConfig = require('./jobber-config.js');

class AuthSetup {
  constructor() {
    this.jobber = new JobberConfig();
  }

  /**
   * Generate OAuth authorization URL
   */
  generateAuthURL() {
    this.jobber.loadCredentials();

    const redirectUri = 'https://homehandymansolutionsllc.com/oauth-callback.html';
    const state = Math.random().toString(36).substring(7);

    const authURL = this.jobber.getAuthorizationURL(redirectUri, state);

    console.log('🔐 Jobber OAuth Authentication Setup');
    console.log('====================================');
    console.log('');
    console.log('Client ID:', this.jobber.clientId);
    console.log('Redirect URI:', redirectUri);
    console.log('State:', state);
    console.log('');
    console.log('🌐 Authorization URL:');
    console.log(authURL);
    console.log('');
    console.log('📋 Instructions:');
    console.log('1. Copy the URL above');
    console.log('2. Open it in your browser');
    console.log('3. Authorize the application');
    console.log('4. Copy the authorization code from the callback');
    console.log('5. Use the code to get access tokens');

    return authURL;
  }

  /**
   * For development, try to use a mock/test token approach
   */
  setupDevTokens() {
    console.log('🔧 Development Token Setup');
    console.log('==========================');
    console.log('');
    console.log('For development purposes, we can try to access the API directly.');
    console.log('In production, you would need to complete the OAuth flow.');
    console.log('');

    // Set mock tokens for testing
    this.jobber.accessToken = 'dev_token_placeholder';
    this.jobber.refreshToken = 'dev_refresh_placeholder';
    this.jobber.tokenExpiry = Date.now() + (24 * 60 * 60 * 1000); // 24 hours

    return true;
  }

  async run() {
    console.log('🚀 Jobber API Authentication Check');
    console.log('==================================');
    console.log('');

    this.jobber.loadCredentials();
    this.jobber.loadStoredTokens();

    if (this.jobber.accessToken) {
      console.log('✅ Access token found!');
      console.log('🕒 Token expiry:', new Date(this.jobber.tokenExpiry).toLocaleString());

      // Test the token
      try {
        const testQuery = `
          query {
            viewer {
              account {
                name
                id
              }
            }
          }
        `;

        const result = await this.jobber.graphqlRequest(testQuery);
        console.log('✅ Token is valid!');
        console.log('🏢 Account:', result.viewer.account.name);
        console.log('🆔 Account ID:', result.viewer.account.id);
        return true;
      } catch (error) {
        console.log('❌ Token is invalid or expired');
        console.log('Error:', error.message);
      }
    }

    console.log('🔑 No valid token found. Setting up authentication...');
    console.log('');

    this.generateAuthURL();
    return false;
  }
}

// Run the script
if (require.main === module) {
  const auth = new AuthSetup();
  auth.run();
}

module.exports = AuthSetup;
