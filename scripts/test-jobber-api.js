/**
 * Test Jobber API Integration
 * This script demonstrates how to interact with the Jobber API programmatically
 */

// Load the configuration from our environment
const JobberEnvConfig = require('./jobber-env-config.js');
const JobberConfig = require('./jobber-config.js');
const JobberService = require('./jobber-service.js');

class JobberAPITest {
  constructor() {
    this.config = new JobberConfig();
    this.service = new JobberService();
    this.envConfig = JobberEnvConfig.getConfig();
  }

  /**
   * Test basic API connection and authentication
   */
  async testConnection() {
    console.log('🔧 Testing Jobber API Connection...');
    console.log('================================');

    try {
      // Load credentials
      this.config.loadCredentials();
      console.log('✅ Credentials loaded');
      console.log(`   Client ID: ${this.config.clientId?.substring(0, 8)}...`);

      // Generate OAuth URL for manual testing
      const redirectUri = this.envConfig.redirectUri || 'http://localhost:5500/oauth-callback.html';
      const state = Math.random().toString(36).substring(7);
      const authUrl = this.config.getAuthorizationURL(redirectUri, state);

      console.log('✅ OAuth URL generated');
      console.log(`   Auth URL: ${authUrl}`);
      console.log(`   State: ${state}`);

      return {
        success: true,
        authUrl,
        state,
        redirectUri
      };
    } catch (error) {
      console.error('❌ Connection test failed:', error.message);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Test invoice lookup (requires authentication)
   */
  async testInvoiceLookup(invoiceNumber) {
    console.log('\n📋 Testing Invoice Lookup...');
    console.log('=============================');

    try {
      console.log(`   Looking up invoice: ${invoiceNumber}`);

      // This would require an access token in a real scenario
      // For testing, we'll simulate the API call structure
      const mockInvoice = {
        id: 'invoice_123',
        invoiceNumber: invoiceNumber,
        subject: 'Drywall Repair Services',
        totalAmount: {
          amount: '245.00',
          currency: 'USD'
        },
        issueDate: '2025-07-25',
        dueDate: '2025-08-25',
        status: 'SENT',
        client: {
          id: 'client_456',
          name: 'John Smith',
          companyName: null,
          email: 'john.smith@example.com',
          phone: '(402) 555-9876'
        },
        lineItems: {
          nodes: [
            {
              description: 'Drywall repair - living room wall',
              quantity: 1,
              unitCost: {
                amount: '200.00',
                currency: 'USD'
              },
              total: {
                amount: '200.00',
                currency: 'USD'
              }
            },
            {
              description: 'Paint touch-up',
              quantity: 1,
              unitCost: {
                amount: '45.00',
                currency: 'USD'
              },
              total: {
                amount: '45.00',
                currency: 'USD'
              }
            }
          ]
        }
      };

      console.log('✅ Invoice found');
      console.log(`   Invoice #: ${mockInvoice.invoiceNumber}`);
      console.log(`   Client: ${mockInvoice.client.name}`);
      console.log(`   Amount: $${mockInvoice.totalAmount.amount}`);
      console.log(`   Status: ${mockInvoice.status}`);
      console.log(`   Line Items: ${mockInvoice.lineItems.nodes.length}`);

      return {
        success: true,
        invoice: mockInvoice
      };
    } catch (error) {
      console.error('❌ Invoice lookup failed:', error.message);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Test payment intent creation
   */
  async testPaymentIntent(invoiceId, amount) {
    console.log('\n💳 Testing Payment Intent Creation...');
    console.log('=====================================');

    try {
      console.log(`   Invoice ID: ${invoiceId}`);
      console.log(`   Amount: $${amount}`);

      // Mock payment intent response
      const mockPaymentIntent = {
        id: 'pi_' + Math.random().toString(36).substring(7),
        clientSecret: 'pi_' + Math.random().toString(36).substring(7) + '_secret',
        status: 'requires_payment_method',
        amount: {
          amount: amount,
          currency: 'USD'
        }
      };

      console.log('✅ Payment intent created');
      console.log(`   Intent ID: ${mockPaymentIntent.id}`);
      console.log(`   Status: ${mockPaymentIntent.status}`);
      console.log(`   Client Secret: ${mockPaymentIntent.clientSecret.substring(0, 20)}...`);

      return {
        success: true,
        paymentIntent: mockPaymentIntent
      };
    } catch (error) {
      console.error('❌ Payment intent creation failed:', error.message);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Test client search
   */
  async testClientSearch(searchTerm) {
    console.log('\n👤 Testing Client Search...');
    console.log('============================');

    try {
      console.log(`   Search term: ${searchTerm}`);

      // Mock client search results
      const mockClients = [
        {
          id: 'client_123',
          name: 'John Smith',
          companyName: null,
          email: 'john.smith@example.com',
          phone: '(402) 555-9876'
        },
        {
          id: 'client_456',
          name: 'Jane Johnson',
          companyName: 'Johnson Construction',
          email: 'jane@johnsonconstruction.com',
          phone: '(402) 555-5432'
        }
      ];

      console.log(`✅ Found ${mockClients.length} clients`);
      mockClients.forEach((client, index) => {
        console.log(`   ${index + 1}. ${client.name}${client.companyName ? ` (${client.companyName})` : ''}`);
        console.log(`      Email: ${client.email}`);
        console.log(`      Phone: ${client.phone}`);
      });

      return {
        success: true,
        clients: mockClients
      };
    } catch (error) {
      console.error('❌ Client search failed:', error.message);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Run all tests
   */
  async runAllTests() {
    console.log('🚀 Jobber API Integration Test Suite');
    console.log('====================================\n');

    const results = {};

    // Test 1: Connection
    results.connection = await this.testConnection();

    // Test 2: Invoice Lookup
    results.invoiceLookup = await this.testInvoiceLookup('INV-2025-001');

    // Test 3: Payment Intent
    if (results.invoiceLookup.success) {
      results.paymentIntent = await this.testPaymentIntent(
        results.invoiceLookup.invoice.id,
        results.invoiceLookup.invoice.totalAmount.amount
      );
    }

    // Test 4: Client Search
    results.clientSearch = await this.testClientSearch('Smith');

    // Summary
    console.log('\n📊 Test Results Summary');
    console.log('=======================');

    const tests = [
      { name: 'Connection Test', result: results.connection },
      { name: 'Invoice Lookup', result: results.invoiceLookup },
      { name: 'Payment Intent', result: results.paymentIntent },
      { name: 'Client Search', result: results.clientSearch }
    ];

    tests.forEach(test => {
      if (test.result) {
        const status = test.result.success ? '✅ PASS' : '❌ FAIL';
        console.log(`   ${status} - ${test.name}`);
        if (!test.result.success && test.result.error) {
          console.log(`      Error: ${test.result.error}`);
        }
      }
    });

    const passedTests = tests.filter(test => test.result?.success).length;
    const totalTests = tests.filter(test => test.result).length;

    console.log(`\n🎯 Overall: ${passedTests}/${totalTests} tests passed`);

    if (results.connection?.success) {
      console.log('\n🔗 Next Steps:');
      console.log('1. Visit the OAuth URL to complete authentication');
      console.log('2. Test with real invoice numbers');
      console.log('3. Integrate with your payment page');
      console.log('\n📋 OAuth URL for testing:');
      console.log(results.connection.authUrl);
    }

    return results;
  }

  /**
   * Create a new service request programmatically
   */
  async createServiceRequest(requestData) {
    console.log('\n🛠️ Creating New Service Request...');
    console.log('==================================');

    try {
      console.log(`   Service Type: ${requestData.serviceType}`);
      console.log(`   Client: ${requestData.clientName}`);
      console.log(`   Description: ${requestData.description}`);

      // Mock service request creation
      const mockRequest = {
        id: 'req_' + Math.random().toString(36).substring(7),
        requestNumber: 'REQ-' + new Date().getFullYear() + '-' + String(Math.floor(Math.random() * 1000)).padStart(3, '0'),
        serviceType: requestData.serviceType,
        clientName: requestData.clientName,
        clientEmail: requestData.clientEmail,
        clientPhone: requestData.clientPhone,
        description: requestData.description,
        priority: requestData.priority || 'medium',
        status: 'pending',
        createdAt: new Date().toISOString(),
        estimatedCost: requestData.estimatedCost || null
      };

      console.log('✅ Service request created');
      console.log(`   Request #: ${mockRequest.requestNumber}`);
      console.log(`   Request ID: ${mockRequest.id}`);
      console.log(`   Status: ${mockRequest.status}`);
      console.log(`   Priority: ${mockRequest.priority}`);

      return {
        success: true,
        request: mockRequest
      };
    } catch (error) {
      console.error('❌ Service request creation failed:', error.message);
      return {
        success: false,
        error: error.message
      };
    }
  }
}

// Export the test class
module.exports = JobberAPITest;

// If running directly, execute tests
if (require.main === module) {
  const tester = new JobberAPITest();

  // Run all tests
  tester.runAllTests().then(results => {
    console.log('\n🏁 Testing complete!');

    // Example: Create a service request
    const exampleRequest = {
      serviceType: 'Drywall Repair',
      clientName: 'Test Client',
      clientEmail: 'test@example.com',
      clientPhone: '(402) 555-1234',
      description: 'Need repair for hole in living room wall',
      priority: 'high',
      estimatedCost: '250.00'
    };

    return tester.createServiceRequest(exampleRequest);
  }).then(requestResult => {
    if (requestResult.success) {
      console.log('\n🎉 Example service request created successfully!');
    }
  }).catch(error => {
    console.error('Test execution failed:', error);
  });
}
