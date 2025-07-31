#!/usr/bin/env node

/**
 * Interactive Jobber API Request Submitter
 * Allows you to create different types of service requests via command line
 */

const JobberAPITest = require('./test-jobber-api.js');
const readline = require('readline');

class InteractiveRequestSubmitter {
  constructor() {
    this.tester = new JobberAPITest();
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
  }

  /**
   * Prompt user for input
   */
  prompt(question) {
    return new Promise((resolve) => {
      this.rl.question(question, resolve);
    });
  }

  /**
   * Display service type menu
   */
  displayServiceTypes() {
    console.log('\n🔧 Available Service Types:');
    console.log('1. Drywall Repair');
    console.log('2. Electrical Work');
    console.log('3. Plumbing');
    console.log('4. Painting');
    console.log('5. Deck/Patio Work');
    console.log('6. Bathroom Remodeling');
    console.log('7. General Handyman');
    console.log('8. Custom/Other');
  }

  /**
   * Get service type from user selection
   */
  getServiceType(selection) {
    const serviceTypes = {
      '1': 'Drywall Repair',
      '2': 'Electrical Work',
      '3': 'Plumbing',
      '4': 'Painting',
      '5': 'Deck/Patio Work',
      '6': 'Bathroom Remodeling',
      '7': 'General Handyman',
      '8': 'Custom/Other'
    };
    return serviceTypes[selection] || 'General Handyman';
  }

  /**
   * Display priority levels
   */
  displayPriorityLevels() {
    console.log('\n⚡ Priority Levels:');
    console.log('1. Low - Can wait a week or more');
    console.log('2. Medium - Within a few days');
    console.log('3. High - Within 24-48 hours');
    console.log('4. Urgent - Same day if possible');
  }

  /**
   * Get priority from user selection
   */
  getPriority(selection) {
    const priorities = {
      '1': 'low',
      '2': 'medium',
      '3': 'high',
      '4': 'urgent'
    };
    return priorities[selection] || 'medium';
  }

  /**
   * Collect service request data from user
   */
  async collectRequestData() {
    console.log('\n📝 Service Request Form');
    console.log('========================');

    // Service Type
    this.displayServiceTypes();
    const serviceSelection = await this.prompt('\nSelect service type (1-8): ');
    const serviceType = this.getServiceType(serviceSelection);

    // Custom service type if selected
    let customServiceType = serviceType;
    if (serviceSelection === '8') {
      customServiceType = await this.prompt('Enter custom service type: ');
    }

    // Client Information
    console.log('\n👤 Client Information:');
    const clientName = await this.prompt('Client name: ');
    const clientEmail = await this.prompt('Client email: ');
    const clientPhone = await this.prompt('Client phone: ');

    // Service Details
    console.log('\n🏠 Service Details:');
    const description = await this.prompt('Description of work needed: ');
    const location = await this.prompt('Property address/location: ');

    // Priority
    this.displayPriorityLevels();
    const prioritySelection = await this.prompt('\nSelect priority (1-4): ');
    const priority = this.getPriority(prioritySelection);

    // Estimated Cost (optional)
    const estimatedCost = await this.prompt('Estimated cost (optional, just number): $');

    // Preferred contact method
    console.log('\n📞 Contact Preferences:');
    console.log('1. Phone call');
    console.log('2. Email');
    console.log('3. Text message');
    console.log('4. Any method');
    const contactMethod = await this.prompt('Preferred contact method (1-4): ');

    // Additional notes
    const additionalNotes = await this.prompt('Additional notes (optional): ');

    return {
      serviceType: customServiceType,
      clientName,
      clientEmail,
      clientPhone,
      description,
      location,
      priority,
      estimatedCost: estimatedCost ? parseFloat(estimatedCost) : null,
      contactMethod,
      additionalNotes,
      submittedAt: new Date().toISOString()
    };
  }

  /**
   * Display request summary
   */
  displayRequestSummary(requestData) {
    console.log('\n📋 Request Summary');
    console.log('==================');
    console.log(`Service Type: ${requestData.serviceType}`);
    console.log(`Client: ${requestData.clientName}`);
    console.log(`Email: ${requestData.clientEmail}`);
    console.log(`Phone: ${requestData.clientPhone}`);
    console.log(`Location: ${requestData.location}`);
    console.log(`Priority: ${requestData.priority.toUpperCase()}`);
    console.log(`Description: ${requestData.description}`);
    if (requestData.estimatedCost) {
      console.log(`Estimated Cost: $${requestData.estimatedCost}`);
    }
    if (requestData.additionalNotes) {
      console.log(`Additional Notes: ${requestData.additionalNotes}`);
    }
    console.log(`Submitted: ${new Date(requestData.submittedAt).toLocaleString()}`);
  }

  /**
   * Submit the request
   */
  async submitRequest(requestData) {
    console.log('\n🚀 Submitting Request...');

    try {
      const result = await this.tester.createServiceRequest(requestData);

      if (result.success) {
        console.log('\n✅ SUCCESS! Service request submitted');
        console.log('====================================');
        console.log(`Request Number: ${result.request.requestNumber}`);
        console.log(`Request ID: ${result.request.id}`);
        console.log(`Status: ${result.request.status}`);
        console.log('');
        console.log('📧 What happens next:');
        console.log('• You\'ll receive a confirmation email shortly');
        console.log('• We\'ll contact you within 24 hours to schedule');
        console.log('• A detailed estimate will be provided before work begins');
        console.log('');
        console.log('📞 Questions? Call us at (402) 555-1234');

        return result.request;
      } else {
        console.error('❌ Failed to submit request:', result.error);
        return null;
      }
    } catch (error) {
      console.error('❌ Error submitting request:', error.message);
      return null;
    }
  }

  /**
   * Main interactive flow
   */
  async run() {
    console.log('🏠 Home Handyman Solutions - Service Request System');
    console.log('===================================================');
    console.log('Welcome! Let\'s create a new service request.\n');

    try {
      // Collect request data
      const requestData = await this.collectRequestData();

      // Show summary
      this.displayRequestSummary(requestData);

      // Confirm submission
      const confirm = await this.prompt('\nSubmit this request? (y/n): ');

      if (confirm.toLowerCase() === 'y' || confirm.toLowerCase() === 'yes') {
        const submittedRequest = await this.submitRequest(requestData);

        if (submittedRequest) {
          // Save to local file for tracking
          const fs = require('fs');
          const requestsFile = '../requests-log.json';

          let requestsLog = [];
          try {
            if (fs.existsSync(requestsFile)) {
              requestsLog = JSON.parse(fs.readFileSync(requestsFile, 'utf8'));
            }
          } catch (error) {
            console.log('Creating new requests log file...');
          }

          requestsLog.push({
            ...requestData,
            requestNumber: submittedRequest.requestNumber,
            requestId: submittedRequest.id,
            status: submittedRequest.status
          });

          fs.writeFileSync(requestsFile, JSON.stringify(requestsLog, null, 2));
          console.log(`📝 Request logged to ${requestsFile}`);
        }
      } else {
        console.log('❌ Request cancelled');
      }
    } catch (error) {
      console.error('❌ Error:', error.message);
    } finally {
      this.rl.close();
    }
  }

  /**
   * Quick request method for common services
   */
  async quickRequest(type) {
    const quickRequests = {
      drywall: {
        serviceType: 'Drywall Repair',
        description: 'Drywall repair needed',
        priority: 'medium'
      },
      electrical: {
        serviceType: 'Electrical Work',
        description: 'Electrical work needed',
        priority: 'high'
      },
      plumbing: {
        serviceType: 'Plumbing',
        description: 'Plumbing issue needs attention',
        priority: 'high'
      },
      painting: {
        serviceType: 'Painting',
        description: 'Painting services needed',
        priority: 'low'
      }
    };

    const template = quickRequests[type];
    if (!template) {
      console.log('❌ Unknown quick request type');
      return;
    }

    console.log(`🚀 Quick ${template.serviceType} Request`);
    console.log('=====================================');

    const clientName = await this.prompt('Client name: ');
    const clientEmail = await this.prompt('Client email: ');
    const clientPhone = await this.prompt('Client phone: ');
    const location = await this.prompt('Property address: ');

    const requestData = {
      ...template,
      clientName,
      clientEmail,
      clientPhone,
      location,
      submittedAt: new Date().toISOString()
    };

    return await this.submitRequest(requestData);
  }
}

// Export the class
module.exports = InteractiveRequestSubmitter;

// If running directly, start interactive mode
if (require.main === module) {
  const submitter = new InteractiveRequestSubmitter();

  // Check for command line arguments for quick requests
  const args = process.argv.slice(2);
  if (args.length > 0 && args[0] === 'quick' && args[1]) {
    submitter.quickRequest(args[1]).then(() => {
      process.exit(0);
    }).catch(error => {
      console.error('Error:', error.message);
      process.exit(1);
    });
  } else {
    submitter.run().then(() => {
      process.exit(0);
    }).catch(error => {
      console.error('Error:', error.message);
      process.exit(1);
    });
  }
}
