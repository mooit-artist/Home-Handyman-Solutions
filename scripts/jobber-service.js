/**
 * Jobber API Service
 * Handles invoice and payment operations
 */

// Import JobberConfig for Node.js environment
const JobberConfig = require('./jobber-config.js');

class JobberService {
  constructor() {
    this.config = new JobberConfig();
    this.config.loadCredentials();
    this.config.loadStoredTokens();
  }

  /**
   * Get invoices for a client
   */
  async getInvoices(clientId = null) {
    const query = `
      query GetInvoices($clientId: ID) {
        invoices(first: 50, filter: { clientId: $clientId }) {
          nodes {
            id
            invoiceNumber
            subject
            totalAmount {
              amount
              currency
            }
            issueDate
            dueDate
            status
            client {
              id
              name
              companyName
            }
            lineItems {
              nodes {
                description
                quantity
                unitCost {
                  amount
                  currency
                }
                total {
                  amount
                  currency
                }
              }
            }
          }
        }
      }
    `;

    return await this.config.graphqlRequest(query, { clientId });
  }

  /**
   * Get a specific invoice by ID or invoice number
   */
  async getInvoice(invoiceId = null, invoiceNumber = null) {
    if (!invoiceId && !invoiceNumber) {
      throw new Error('Either invoiceId or invoiceNumber must be provided');
    }

    let query;
    let variables = {};

    if (invoiceId) {
      query = `
        query GetInvoice($id: ID!) {
          invoice(id: $id) {
            id
            invoiceNumber
            subject
            totalAmount {
              amount
              currency
            }
            issueDate
            dueDate
            status
            client {
              id
              name
              companyName
              email
              phone
            }
            lineItems {
              nodes {
                description
                quantity
                unitCost {
                  amount
                  currency
                }
                total {
                  amount
                  currency
                }
              }
            }
          }
        }
      `;
      variables = { id: invoiceId };
    } else {
      // Search by invoice number
      query = `
        query SearchInvoices($invoiceNumber: String!) {
          invoices(first: 1, filter: { invoiceNumber: $invoiceNumber }) {
            nodes {
              id
              invoiceNumber
              subject
              totalAmount {
                amount
                currency
              }
              issueDate
              dueDate
              status
              client {
                id
                name
                companyName
                email
                phone
              }
              lineItems {
                nodes {
                  description
                  quantity
                  unitCost {
                    amount
                    currency
                  }
                  total {
                    amount
                    currency
                  }
                }
              }
            }
          }
        }
      `;
      variables = { invoiceNumber };
    }

    const result = await this.config.graphqlRequest(query, variables);

    if (invoiceId) {
      return result.invoice;
    } else {
      return result.invoices.nodes[0] || null;
    }
  }

  /**
   * Create a payment intent for an invoice
   */
  async createPaymentIntent(invoiceId, amount, paymentMethod = 'card') {
    const query = `
      mutation CreatePaymentIntent($invoiceId: ID!, $amount: MoneyInput!, $paymentMethod: String!) {
        createPaymentIntent(input: {
          invoiceId: $invoiceId
          amount: $amount
          paymentMethod: $paymentMethod
        }) {
          paymentIntent {
            id
            clientSecret
            status
            amount {
              amount
              currency
            }
          }
          userErrors {
            field
            message
          }
        }
      }
    `;

    return await this.config.graphqlRequest(query, {
      invoiceId,
      amount,
      paymentMethod
    });
  }

  /**
   * Record a payment for an invoice
   */
  async recordPayment(invoiceId, amount, paymentMethod, paymentDate = null) {
    const query = `
      mutation RecordPayment($invoiceId: ID!, $amount: MoneyInput!, $paymentMethod: String!, $paymentDate: Date) {
        recordPayment(input: {
          invoiceId: $invoiceId
          amount: $amount
          paymentMethod: $paymentMethod
          paymentDate: $paymentDate
        }) {
          payment {
            id
            amount {
              amount
              currency
            }
            paymentMethod
            paymentDate
          }
          userErrors {
            field
            message
          }
        }
      }
    `;

    return await this.config.graphqlRequest(query, {
      invoiceId,
      amount,
      paymentMethod,
      paymentDate: paymentDate || new Date().toISOString().split('T')[0]
    });
  }

  /**
   * Get client information
   */
  async getClient(clientId) {
    const query = `
      query GetClient($id: ID!) {
        client(id: $id) {
          id
          name
          companyName
          email
          phone
          billingAddress {
            street1
            street2
            city
            province
            postalCode
            country
          }
        }
      }
    `;

    return await this.config.graphqlRequest(query, { id: clientId });
  }

  /**
   * Search for clients
   */
  async searchClients(searchTerm) {
    const query = `
      query SearchClients($searchTerm: String!) {
        clients(first: 10, filter: { search: $searchTerm }) {
          nodes {
            id
            name
            companyName
            email
            phone
          }
        }
      }
    `;

    return await this.config.graphqlRequest(query, { searchTerm });
  }

  /**
   * Get payment status for an invoice
   */
  async getPaymentStatus(invoiceId) {
    const query = `
      query GetPaymentStatus($invoiceId: ID!) {
        invoice(id: $invoiceId) {
          id
          status
          totalAmount {
            amount
            currency
          }
          paidAmount {
            amount
            currency
          }
          payments {
            nodes {
              id
              amount {
                amount
                currency
              }
              paymentMethod
              paymentDate
              status
            }
          }
        }
      }
    `;

    return await this.config.graphqlRequest(query, { invoiceId });
  }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = JobberService;
} else {
  window.JobberService = JobberService;
}
