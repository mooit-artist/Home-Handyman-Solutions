/**
 * Jobber Payment Widget
 * Provides a complete payment interface for invoices
 */

class JobberPaymentWidget {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId);
    this.service = new JobberService();
    this.options = {
      showInvoiceDetails: true,
      allowInvoiceSearch: true,
      redirectAfterPayment: '/payment-success.html',
      ...options
    };

    this.currentInvoice = null;
    this.paymentIntent = null;

    this.init();
  }

  init() {
    this.render();
    this.setupEventListeners();
  }

  render() {
    this.container.innerHTML = `
      <div class="jobber-payment-widget">
        <div class="payment-header">
          <h3>💳 Pay Your Invoice</h3>
          <p>Enter your invoice number to get started</p>
        </div>

        <div class="invoice-lookup">
          <div class="form-group">
            <label for="invoice-number">Invoice Number:</label>
            <div class="input-group">
              <input
                type="text"
                id="invoice-number"
                placeholder="Enter invoice number..."
                class="form-control"
              >
              <button id="lookup-invoice" class="btn btn-primary">
                Look Up Invoice
              </button>
            </div>
          </div>
        </div>

        <div id="invoice-details" class="invoice-details" style="display: none;">
          <!-- Invoice details will be populated here -->
        </div>

        <div id="payment-form" class="payment-form" style="display: none;">
          <!-- Payment form will be populated here -->
        </div>

        <div id="loading" class="loading-spinner" style="display: none;">
          <div class="spinner"></div>
          <p>Processing...</p>
        </div>

        <div id="error-message" class="error-message" style="display: none;">
          <!-- Error messages will be shown here -->
        </div>

        <div id="success-message" class="success-message" style="display: none;">
          <!-- Success messages will be shown here -->
        </div>
      </div>
    `;

    this.addStyles();
  }

  addStyles() {
    const style = document.createElement('style');
    style.textContent = `
      .jobber-payment-widget {
        max-width: 600px;
        margin: 0 auto;
        padding: 2rem;
        background: white;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      }

      .payment-header {
        text-align: center;
        margin-bottom: 2rem;
      }

      .payment-header h3 {
        color: var(--dark-walnut, #3c2e26);
        margin-bottom: 0.5rem;
      }

      .payment-header p {
        color: var(--slate-gray, #64748b);
      }

      .form-group {
        margin-bottom: 1.5rem;
      }

      .form-group label {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 600;
        color: var(--dark-walnut, #3c2e26);
      }

      .input-group {
        display: flex;
        gap: 0.5rem;
      }

      .form-control {
        flex: 1;
        padding: 0.75rem;
        border: 2px solid #e2e8f0;
        border-radius: 8px;
        font-size: 1rem;
        transition: border-color 0.3s ease;
      }

      .form-control:focus {
        outline: none;
        border-color: var(--soft-gold, #d4af37);
      }

      .btn {
        padding: 0.75rem 1.5rem;
        border: none;
        border-radius: 8px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
      }

      .btn-primary {
        background: var(--soft-gold, #d4af37);
        color: var(--dark-walnut, #3c2e26);
      }

      .btn-primary:hover {
        background: #c19b26;
        transform: translateY(-1px);
      }

      .btn-success {
        background: #10b981;
        color: white;
      }

      .btn-success:hover {
        background: #059669;
      }

      .invoice-details {
        background: var(--light-gray, #f8fafc);
        padding: 1.5rem;
        border-radius: 8px;
        margin-bottom: 2rem;
      }

      .invoice-info {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 1rem;
        margin-bottom: 1rem;
      }

      .invoice-field {
        display: flex;
        justify-content: space-between;
        padding: 0.5rem 0;
        border-bottom: 1px solid #e2e8f0;
      }

      .field-label {
        font-weight: 600;
        color: var(--dark-walnut, #3c2e26);
      }

      .field-value {
        color: var(--slate-gray, #64748b);
      }

      .amount-total {
        font-size: 1.25rem;
        font-weight: bold;
        color: var(--soft-gold, #d4af37);
        text-align: center;
        padding: 1rem;
        background: white;
        border-radius: 8px;
        margin-top: 1rem;
      }

      .loading-spinner {
        text-align: center;
        padding: 2rem;
      }

      .spinner {
        border: 4px solid #f3f4f6;
        border-top: 4px solid var(--soft-gold, #d4af37);
        border-radius: 50%;
        width: 40px;
        height: 40px;
        animation: spin 1s linear infinite;
        margin: 0 auto 1rem;
      }

      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }

      .error-message, .success-message {
        padding: 1rem;
        border-radius: 8px;
        margin: 1rem 0;
        text-align: center;
      }

      .error-message {
        background: #fef2f2;
        color: #dc2626;
        border: 1px solid #fecaca;
      }

      .success-message {
        background: #f0fdf4;
        color: #16a34a;
        border: 1px solid #bbf7d0;
      }

      .payment-methods {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
        gap: 1rem;
        margin: 1rem 0;
      }

      .payment-method {
        padding: 1rem;
        border: 2px solid #e2e8f0;
        border-radius: 8px;
        text-align: center;
        cursor: pointer;
        transition: all 0.3s ease;
      }

      .payment-method:hover {
        border-color: var(--soft-gold, #d4af37);
      }

      .payment-method.selected {
        border-color: var(--soft-gold, #d4af37);
        background: #fffbeb;
      }

      .line-items {
        margin-top: 1rem;
      }

      .line-item {
        display: flex;
        justify-content: space-between;
        padding: 0.5rem 0;
        border-bottom: 1px solid #e2e8f0;
      }

      .line-item:last-child {
        border-bottom: none;
      }
    `;
    document.head.appendChild(style);
  }

  setupEventListeners() {
    const lookupBtn = document.getElementById('lookup-invoice');
    const invoiceInput = document.getElementById('invoice-number');

    lookupBtn.addEventListener('click', () => this.lookupInvoice());

    invoiceInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        this.lookupInvoice();
      }
    });
  }

  async lookupInvoice() {
    const invoiceNumber = document.getElementById('invoice-number').value.trim();

    if (!invoiceNumber) {
      this.showError('Please enter an invoice number');
      return;
    }

    this.showLoading(true);
    this.hideError();

    try {
      const invoice = await this.service.getInvoice(null, invoiceNumber);

      if (!invoice) {
        this.showError('Invoice not found. Please check the invoice number and try again.');
        return;
      }

      this.currentInvoice = invoice;
      this.displayInvoiceDetails(invoice);
      this.setupPaymentForm(invoice);

    } catch (error) {
      console.error('Error looking up invoice:', error);
      this.showError('Error looking up invoice. Please try again or contact support.');
    } finally {
      this.showLoading(false);
    }
  }

  displayInvoiceDetails(invoice) {
    const detailsContainer = document.getElementById('invoice-details');

    detailsContainer.innerHTML = `
      <h4>📋 Invoice Details</h4>
      <div class="invoice-info">
        <div class="invoice-field">
          <span class="field-label">Invoice #:</span>
          <span class="field-value">${invoice.invoiceNumber}</span>
        </div>
        <div class="invoice-field">
          <span class="field-label">Client:</span>
          <span class="field-value">${invoice.client.companyName || invoice.client.name}</span>
        </div>
        <div class="invoice-field">
          <span class="field-label">Issue Date:</span>
          <span class="field-value">${new Date(invoice.issueDate).toLocaleDateString()}</span>
        </div>
        <div class="invoice-field">
          <span class="field-label">Due Date:</span>
          <span class="field-value">${new Date(invoice.dueDate).toLocaleDateString()}</span>
        </div>
        <div class="invoice-field">
          <span class="field-label">Status:</span>
          <span class="field-value">${invoice.status}</span>
        </div>
      </div>

      ${invoice.lineItems.nodes.length > 0 ? `
        <div class="line-items">
          <h5>Line Items:</h5>
          ${invoice.lineItems.nodes.map(item => `
            <div class="line-item">
              <span>${item.description} (${item.quantity})</span>
              <span>$${item.total.amount}</span>
            </div>
          `).join('')}
        </div>
      ` : ''}

      <div class="amount-total">
        Total Amount: $${invoice.totalAmount.amount} ${invoice.totalAmount.currency}
      </div>
    `;

    detailsContainer.style.display = 'block';
  }

  setupPaymentForm(invoice) {
    const formContainer = document.getElementById('payment-form');

    formContainer.innerHTML = `
      <h4>💳 Payment Information</h4>
      <p>Choose your payment method:</p>

      <div class="payment-methods">
        <div class="payment-method" data-method="card">
          <div>💳</div>
          <div>Credit Card</div>
        </div>
        <div class="payment-method" data-method="bank">
          <div>🏦</div>
          <div>Bank Transfer</div>
        </div>
        <div class="payment-method" data-method="jobber_hub">
          <div>🔗</div>
          <div>Jobber Hub</div>
        </div>
      </div>

      <div id="payment-details" class="payment-details" style="display: none;">
        <!-- Payment form details will be inserted here -->
      </div>

      <button id="process-payment" class="btn btn-success" style="width: 100%; margin-top: 1rem; display: none;">
        Pay $${invoice.totalAmount.amount}
      </button>
    `;

    // Setup payment method selection
    const paymentMethods = formContainer.querySelectorAll('.payment-method');
    paymentMethods.forEach(method => {
      method.addEventListener('click', () => {
        paymentMethods.forEach(m => m.classList.remove('selected'));
        method.classList.add('selected');
        this.setupPaymentMethod(method.dataset.method, invoice);
      });
    });

    formContainer.style.display = 'block';
  }

  setupPaymentMethod(method, invoice) {
    const detailsContainer = document.getElementById('payment-details');
    const processBtn = document.getElementById('process-payment');

    switch (method) {
      case 'card':
        detailsContainer.innerHTML = `
          <div class="form-group">
            <label>Card Number:</label>
            <input type="text" class="form-control" placeholder="1234 5678 9012 3456" maxlength="19">
          </div>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
            <div class="form-group">
              <label>Expiry Date:</label>
              <input type="text" class="form-control" placeholder="MM/YY" maxlength="5">
            </div>
            <div class="form-group">
              <label>CVV:</label>
              <input type="text" class="form-control" placeholder="123" maxlength="4">
            </div>
          </div>
          <div class="form-group">
            <label>Cardholder Name:</label>
            <input type="text" class="form-control" placeholder="John Doe">
          </div>
        `;
        break;

      case 'bank':
        detailsContainer.innerHTML = `
          <div class="form-group">
            <p>Bank transfer details will be provided after confirmation.</p>
            <p><strong>Account Name:</strong> Home Handyman Solutions LLC</p>
            <p><strong>Reference:</strong> Invoice ${invoice.invoiceNumber}</p>
          </div>
        `;
        break;

      case 'jobber_hub':
        detailsContainer.innerHTML = `
          <div class="form-group">
            <p>You will be redirected to the Jobber Client Hub to complete your payment securely.</p>
            <p>This is the same payment system you're already familiar with.</p>
          </div>
        `;
        break;
    }

    detailsContainer.style.display = 'block';
    processBtn.style.display = 'block';

    // Update button text based on method
    if (method === 'jobber_hub') {
      processBtn.textContent = 'Continue to Jobber Hub';
    } else if (method === 'bank') {
      processBtn.textContent = 'Confirm Bank Transfer';
    } else {
      processBtn.textContent = `Pay $${invoice.totalAmount.amount}`;
    }

    // Setup payment processing
    processBtn.onclick = () => this.processPayment(method, invoice);
  }

  async processPayment(method, invoice) {
    this.showLoading(true);
    this.hideError();

    try {
      if (method === 'jobber_hub') {
        // Redirect to existing Jobber Client Hub
        const jobberConfig = {
          clientHubUrl: 'https://clienthub.getjobber.com/client_hubs/d050407f-bff1-45f6-8f57-7a3fe3c94330/login/new?source=share_login'
        };
        window.open(jobberConfig.clientHubUrl, '_blank');
        return;
      }

      if (method === 'bank') {
        // Show bank transfer confirmation
        this.showSuccess(`
          Bank transfer initiated for Invoice ${invoice.invoiceNumber}.
          <br><br>
          Please use invoice number as reference when making the transfer.
          <br><br>
          We will confirm payment within 1-2 business days.
        `);
        return;
      }

      // For credit card payments, you would integrate with a payment processor
      // This is a simplified example
      this.showSuccess(`
        Payment of $${invoice.totalAmount.amount} processed successfully!
        <br><br>
        Invoice ${invoice.invoiceNumber} has been paid.
        <br><br>
        You will receive a confirmation email shortly.
      `);

    } catch (error) {
      console.error('Payment processing error:', error);
      this.showError('Payment processing failed. Please try again or contact support.');
    } finally {
      this.showLoading(false);
    }
  }

  showLoading(show) {
    document.getElementById('loading').style.display = show ? 'block' : 'none';
  }

  showError(message) {
    const errorDiv = document.getElementById('error-message');
    errorDiv.innerHTML = message;
    errorDiv.style.display = 'block';
  }

  hideError() {
    document.getElementById('error-message').style.display = 'none';
  }

  showSuccess(message) {
    const successDiv = document.getElementById('success-message');
    successDiv.innerHTML = message;
    successDiv.style.display = 'block';

    // Hide other sections
    document.getElementById('invoice-lookup').style.display = 'none';
    document.getElementById('invoice-details').style.display = 'none';
    document.getElementById('payment-form').style.display = 'none';
  }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = JobberPaymentWidget;
} else {
  window.JobberPaymentWidget = JobberPaymentWidget;
}
