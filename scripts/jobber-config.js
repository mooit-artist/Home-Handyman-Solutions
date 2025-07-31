/**
 * Jobber API Configuration
 * This file handles Jobber API authentication and configuration
 */

class JobberConfig {
  constructor() {
    this.baseURL = 'https://api.getjobber.com/api/graphql';
    this.clientId = null;
    this.clientSecret = null;
    this.accessToken = null;
    this.refreshToken = null;
    this.tokenExpiry = null;
  }

  /**
   * Load credentials from environment or config
   * In production, these should come from environment variables
   */
  loadCredentials() {
    // For development - in production, use environment variables
    // Note: In browser context, we use hardcoded values (not secure for production)
    this.clientId = '92cf415d-f396-4bef-8807-a651d5569964';
    this.clientSecret = 'b84a345305b241bdd4df87795428e338d0d05a6f27b76b8d08c3c96655823233';
  }

  /**
   * OAuth 2.0 Authorization URL for Jobber
   */
  getAuthorizationURL(redirectUri, state) {
    const params = new URLSearchParams({
      client_id: this.clientId,
      redirect_uri: redirectUri,
      response_type: 'code',
      scope: 'read_invoices write_invoices read_clients write_clients read_payments write_payments',
      state: state || Math.random().toString(36).substring(7)
    });

    return `https://api.getjobber.com/api/oauth/authorize?${params.toString()}`;
  }

  /**
   * Exchange authorization code for access token
   */
  async exchangeCodeForToken(code, redirectUri) {
    try {
      // Prepare form data as required by Jobber OAuth
      const formData = new URLSearchParams({
        client_id: this.clientId,
        client_secret: this.clientSecret,
        code: code,
        grant_type: 'authorization_code',
        redirect_uri: redirectUri
      });

      const response = await fetch('https://api.getjobber.com/api/oauth/token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString()
      });

      if (!response.ok) {
        throw new Error(`Token exchange failed: ${response.statusText}`);
      }

      const tokenData = await response.json();

      this.accessToken = tokenData.access_token;
      this.refreshToken = tokenData.refresh_token;

      // Handle expires_in - default to 1 hour if not provided
      const expiresInSeconds = tokenData.expires_in || 3600; // 1 hour default
      this.tokenExpiry = Date.now() + (expiresInSeconds * 1000);

      // Store tokens securely (implement proper storage)
      this.storeTokens(tokenData);

      return tokenData;
    } catch (error) {
      console.error('Error exchanging code for token:', error);
      throw error;
    }
  }

  /**
   * Refresh access token using refresh token
   * Note: With Refresh Token Rotation ON, this generates a NEW refresh token
   * that must replace the old one to prevent invalidation
   */
  async refreshAccessToken() {
    if (!this.refreshToken) {
      throw new Error('No refresh token available');
    }

    try {
      const currentRefreshToken = this.refreshToken; // Store current token

      const formData = new URLSearchParams({
        client_id: this.clientId,
        client_secret: this.clientSecret,
        refresh_token: currentRefreshToken,
        grant_type: 'refresh_token'
      });

      const response = await fetch('https://api.getjobber.com/api/oauth/token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString()
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Token refresh failed: ${response.status} ${response.statusText} - ${errorText}`);
      }

      const tokenData = await response.json();

      // Log warning if present (helps with debugging rotation settings)
      if (tokenData.warning) {
        console.warn('Jobber API Warning:', tokenData.warning);
      }

      // Update tokens immediately to prevent race conditions
      this.accessToken = tokenData.access_token;

      // CRITICAL: Always update refresh token even if it looks the same
      // With rotation ON, this will be a new token
      // With rotation OFF, it will be the same but we should still store it
      if (tokenData.refresh_token) {
        this.refreshToken = tokenData.refresh_token;
      }

      // Handle expires_in - default to 1 hour if not provided
      const expiresInSeconds = tokenData.expires_in || 3600; // 1 hour default
      this.tokenExpiry = Date.now() + (expiresInSeconds * 1000);

      // Store updated tokens immediately
      this.storeTokens(tokenData);

      console.log('Token refresh successful. New expiry:', new Date(this.tokenExpiry));

      return tokenData;
    } catch (error) {
      console.error('Error refreshing token:', error);
      // If refresh fails, clear tokens to force re-authentication
      this.clearTokens();
      throw error;
    }
  }

  /**
   * Check if token is valid and refresh if necessary
   */
  async ensureValidToken() {
    if (!this.accessToken) {
      throw new Error('No access token available. Please authenticate first.');
    }

    // Check if token expires in the next 5 minutes
    if (this.tokenExpiry && (this.tokenExpiry - Date.now()) < 5 * 60 * 1000) {
      await this.refreshAccessToken();
    }
  }

  /**
   * Make authenticated GraphQL request to Jobber API
   */
  async graphqlRequest(query, variables = {}) {
    await this.ensureValidToken();

    try {
      const response = await fetch(this.baseURL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.accessToken}`,
          'X-JOBBER-GRAPHQL-VERSION': '2022-01-01'
        },
        body: JSON.stringify({
          query: query,
          variables: variables
        })
      });

      if (!response.ok) {
        throw new Error(`GraphQL request failed: ${response.statusText}`);
      }

      const data = await response.json();

      if (data.errors) {
        throw new Error(`GraphQL errors: ${JSON.stringify(data.errors)}`);
      }

      return data.data;
    } catch (error) {
      console.error('GraphQL request error:', error);
      throw error;
    }
  }

  /**
   * Store tokens securely (implement based on your needs)
   * CRITICAL: Always store the latest refresh token to handle rotation
   */
  storeTokens(tokenData) {
    // In a real application, store these securely
    // For now, using localStorage (not recommended for production)
    if (typeof localStorage !== 'undefined') {
      if (tokenData.access_token) {
        localStorage.setItem('jobber_access_token', tokenData.access_token);
      }

      // CRITICAL: Always store refresh token if provided
      // With rotation ON, this is a new token that must replace the old one
      if (tokenData.refresh_token) {
        localStorage.setItem('jobber_refresh_token', tokenData.refresh_token);
      }

      if (this.tokenExpiry) {
        localStorage.setItem('jobber_token_expiry', this.tokenExpiry.toString());
      }
    }
  }

  /**
   * Load stored tokens
   */
  loadStoredTokens() {
    if (typeof localStorage !== 'undefined') {
      this.accessToken = localStorage.getItem('jobber_access_token');
      this.refreshToken = localStorage.getItem('jobber_refresh_token');
      const expiry = localStorage.getItem('jobber_token_expiry');
      this.tokenExpiry = expiry ? parseInt(expiry) : null;
    }
  }

  /**
   * Clear all stored tokens (used when refresh fails)
   */
  clearTokens() {
    this.accessToken = null;
    this.refreshToken = null;
    this.tokenExpiry = null;

    if (typeof localStorage !== 'undefined') {
      localStorage.removeItem('jobber_access_token');
      localStorage.removeItem('jobber_refresh_token');
      localStorage.removeItem('jobber_token_expiry');
    }
  }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = JobberConfig;
} else {
  window.JobberConfig = JobberConfig;
}
