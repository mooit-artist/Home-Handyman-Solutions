// Jobber API Environment Configuration
// This file should be used for development only
// In production, use environment variables or a secure config service

const JobberEnvConfig = {
  // Development credentials (move to environment variables in production)
  development: {
    clientId: '92cf415d-f396-4bef-8807-a651d5569964',
    clientSecret: 'b84a345305b241bdd4df87795428e338d0d05a6f27b76b8d08c3c96655823233',
    apiUrl: 'https://api.getjobber.com/api/graphql',
    oauthUrl: 'https://api.getjobber.com/api/oauth',
    clientHubUrl: 'https://clienthub.getjobber.com/client_hubs/d050407f-bff1-45f6-8f57-7a3fe3c94330/login/new?source=share_login',
    scopes: [
      'read_invoices',
      'write_invoices',
      'read_clients',
      'write_clients',
      'read_payments',
      'write_payments'
    ]
  },

  // Production credentials (use environment variables)
  production: {
    clientId: process.env.JOBBER_CLIENT_ID || '92cf415d-f396-4bef-8807-a651d5569964',
    clientSecret: process.env.JOBBER_CLIENT_SECRET || 'b84a345305b241bdd4df87795428e338d0d05a6f27b76b8d08c3c96655823233',
    apiUrl: 'https://api.getjobber.com/api/graphql',
    oauthUrl: 'https://api.getjobber.com/api/oauth',
    clientHubUrl: 'https://clienthub.getjobber.com/client_hubs/d050407f-bff1-45f6-8f57-7a3fe3c94330/login/new?source=share_login',
    scopes: [
      'read_invoices',
      'write_invoices',
      'read_clients',
      'write_clients',
      'read_payments',
      'write_payments'
    ]
  },

  // Get configuration based on environment
  getConfig() {
    const env = process.env.NODE_ENV || 'development';
    return this[env] || this.development;
  },

  // OAuth Configuration
  oauth: {
    redirectUri: 'https://homehandymansolutionsllc.com/oauth/callback',
    state: null,

    generateState() {
      this.state = Math.random().toString(36).substring(2, 15) +
                   Math.random().toString(36).substring(2, 15);
      return this.state;
    },

    validateState(receivedState) {
      return this.state === receivedState;
    }
  },

  // Security settings
  security: {
    tokenStorage: 'localStorage', // 'localStorage', 'sessionStorage', 'cookie', or 'memory'
    tokenPrefix: 'jobber_',
    encryptTokens: false, // Set to true in production with proper encryption
    csrfProtection: true,
    corsOrigins: [
      'https://homehandymansolutionsllc.com',
      'https://api.getjobber.com',
      'https://clienthub.getjobber.com'
    ]
  },

  // API Rate limiting
  rateLimiting: {
    requestsPerMinute: 60,
    burstLimit: 10,
    retryDelay: 1000 // milliseconds
  },

  // Error handling
  errorHandling: {
    maxRetries: 3,
    retryDelay: 1000,
    timeoutMs: 30000,
    logErrors: true,
    showUserErrors: true
  }
};

// Export configuration
if (typeof module !== 'undefined' && module.exports) {
  module.exports = JobberEnvConfig;
} else {
  window.JobberEnvConfig = JobberEnvConfig;
}
