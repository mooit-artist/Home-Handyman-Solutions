#!/usr/bin/env node

/**
 * List Customers from Jobber API
 * This script retrieves and displays all customers from your Jobber account
 */

const JobberConfig = require('./jobber-config.js');
const fs = require('fs');

class CustomerManager {
  constructor() {
    this.jobber = new JobberConfig();
  }

  /**
   * GraphQL query to fetch customers
   */
  getCustomersQuery() {
    return `
      query GetCustomers($first: Int, $after: String) {
        clients(first: $first, after: $after) {
          nodes {
            id
            name
            firstName
            lastName
            companyName
            emails {
              address
              primary
            }
            phoneNumbers {
              number
              primary
            }
            addresses {
              street
              street2
              city
              province
              postalCode
              country
            }
            createdAt
            updatedAt
            tags
            notes
          }
          pageInfo {
            hasNextPage
            endCursor
          }
          totalCount
        }
      }
    `;
  }

  /**
   * Fetch all customers with pagination
   */
  async fetchAllCustomers() {
    console.log('🏢 Fetching Customers from Jobber API');
    console.log('=====================================');
    console.log('');

    try {
      // Load credentials and check authentication
      this.jobber.loadCredentials();
      this.jobber.loadStoredTokens();

      let allCustomers = [];
      let hasNextPage = true;
      let cursor = null;
      let page = 1;

      while (hasNextPage) {
        console.log(`📄 Fetching page ${page}...`);

        const variables = {
          first: 50, // Fetch 50 customers at a time
          after: cursor
        };

        const data = await this.jobber.graphqlRequest(this.getCustomersQuery(), variables);

        if (data && data.clients) {
          const customers = data.clients.nodes;
          allCustomers = allCustomers.concat(customers);

          hasNextPage = data.clients.pageInfo.hasNextPage;
          cursor = data.clients.pageInfo.endCursor;

          console.log(`   ✅ Retrieved ${customers.length} customers`);
          page++;
        } else {
          break;
        }
      }

      console.log('');
      console.log(`🎯 Total Customers Found: ${allCustomers.length}`);
      console.log('');

      return allCustomers;
    } catch (error) {
      console.error('❌ Error fetching customers:', error.message);
      throw error;
    }
  }

  /**
   * Format and display customers
   */
  displayCustomers(customers) {
    if (!customers || customers.length === 0) {
      console.log('📭 No customers found.');
      return;
    }

    console.log('👥 CUSTOMER LIST');
    console.log('===============');
    console.log('');

    customers.forEach((customer, index) => {
      const displayName = customer.companyName || `${customer.firstName || ''} ${customer.lastName || ''}`.trim() || customer.name || 'Unknown';
      const primaryEmail = customer.emails?.find(e => e.primary)?.address || customer.emails?.[0]?.address || 'No email';
      const primaryPhone = customer.phoneNumbers?.find(p => p.primary)?.number || customer.phoneNumbers?.[0]?.number || 'No phone';

      let address = 'No address';
      if (customer.addresses && customer.addresses.length > 0) {
        const addr = customer.addresses[0];
        address = `${addr.street || ''} ${addr.city || ''} ${addr.province || ''} ${addr.postalCode || ''}`.trim();
      }

      console.log(`${(index + 1).toString().padStart(3)}. ${displayName}`);
      console.log(`     📧 ${primaryEmail}`);
      console.log(`     📞 ${primaryPhone}`);
      console.log(`     🏠 ${address}`);

      if (customer.tags && customer.tags.length > 0) {
        console.log(`     🏷️  Tags: ${customer.tags.join(', ')}`);
      }

      if (customer.notes) {
        const shortNotes = customer.notes.length > 100 ? customer.notes.substring(0, 100) + '...' : customer.notes;
        console.log(`     📝 Notes: ${shortNotes}`);
      }

      console.log(`     📅 Created: ${new Date(customer.createdAt).toLocaleDateString()}`);
      console.log('');
    });

    // Summary statistics
    const companiesCount = customers.filter(c => c.companyName).length;
    const individualsCount = customers.length - companiesCount;
    const withEmailCount = customers.filter(c => c.emails && c.emails.length > 0).length;
    const withPhoneCount = customers.filter(c => c.phoneNumbers && c.phoneNumbers.length > 0).length;

    console.log('📊 CUSTOMER STATISTICS');
    console.log('======================');
    console.log(`Total Customers: ${customers.length}`);
    console.log(`Companies: ${companiesCount}`);
    console.log(`Individuals: ${individualsCount}`);
    console.log(`With Email: ${withEmailCount}`);
    console.log(`With Phone: ${withPhoneCount}`);
  }

  /**
   * Save customers to JSON file
   */
  saveCustomersToFile(customers) {
    const filename = '../customer-list.json';
    const data = {
      exportDate: new Date().toISOString(),
      totalCount: customers.length,
      customers: customers
    };

    try {
      fs.writeFileSync(filename, JSON.stringify(data, null, 2));
      console.log('');
      console.log(`💾 Customer list saved to: ${filename}`);
    } catch (error) {
      console.error('❌ Error saving customer list:', error.message);
    }
  }

  /**
   * Main execution function
   */
  async run() {
    try {
      const customers = await this.fetchAllCustomers();
      this.displayCustomers(customers);
      this.saveCustomersToFile(customers);

      console.log('');
      console.log('✅ Customer list retrieval complete!');
    } catch (error) {
      console.error('❌ Failed to retrieve customer list:', error.message);

      if (error.message.includes('No access token')) {
        console.log('');
        console.log('💡 To fix this, you need to authenticate with Jobber first.');
        console.log('   Run the OAuth flow or set up your access tokens.');
      }

      process.exit(1);
    }
  }
}

// Run the script
if (require.main === module) {
  const manager = new CustomerManager();
  manager.run();
}

module.exports = CustomerManager;
