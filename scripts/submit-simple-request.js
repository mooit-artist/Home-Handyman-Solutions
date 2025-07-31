#!/usr/bin/env node

/**
 * Simple Request Submitter
 * Submit a service request programmatically with predefined data
 */

const JobberAPITest = require('./test-jobber-api.js');

async function submitProgrammaticRequest() {
  console.log('🚀 Submitting Service Request Programmatically');
  console.log('==============================================\n');

  const tester = new JobberAPITest();

  // Example service request data
  const requestData = {
    serviceType: 'Drywall Repair',
    clientName: 'John Doe',
    clientEmail: 'john.doe@example.com',
    clientPhone: '(402) 555-1234',
    description: 'Need repair for hole in living room wall caused by moving furniture. Hole is approximately 6 inches in diameter.',
    location: '123 Main Street, Omaha, NE 68102',
    priority: 'high',
    estimatedCost: '250.00',
    contactMethod: 'phone',
    additionalNotes: 'Would prefer morning appointment if possible. Dog on property - please call before arrival.',
    submittedAt: new Date().toISOString(),
    serviceArea: 'Omaha Metro',
    propertyType: 'Single Family Home',
    urgency: 'Within 48 hours',
    materials: 'Client will provide paint for touch-up',
    accessInstructions: 'Side door entrance, knock loudly'
  };

  console.log('📋 Request Details:');
  console.log('==================');
  console.log(`Service: ${requestData.serviceType}`);
  console.log(`Client: ${requestData.clientName}`);
  console.log(`Contact: ${requestData.clientEmail} | ${requestData.clientPhone}`);
  console.log(`Location: ${requestData.location}`);
  console.log(`Priority: ${requestData.priority.toUpperCase()}`);
  console.log(`Description: ${requestData.description}`);
  console.log(`Estimated Cost: $${requestData.estimatedCost}`);
  console.log(`Additional Notes: ${requestData.additionalNotes}`);
  console.log('');

  try {
    // Submit the request
    console.log('⏳ Submitting request...');
    const result = await tester.createServiceRequest(requestData);

    if (result.success) {
      console.log('✅ SUCCESS! Request submitted successfully');
      console.log('=========================================');
      console.log(`Request Number: ${result.request.requestNumber}`);
      console.log(`Request ID: ${result.request.id}`);
      console.log(`Status: ${result.request.status}`);
      console.log(`Priority: ${result.request.priority}`);
      console.log(`Created: ${new Date(result.request.createdAt).toLocaleString()}`);

      // Save to JSON file for tracking
      const fs = require('fs');
      const requestsFile = '../submitted-requests.json';

      let requests = [];
      try {
        if (fs.existsSync(requestsFile)) {
          const fileContent = fs.readFileSync(requestsFile, 'utf8');
          requests = JSON.parse(fileContent);
        }
      } catch (error) {
        console.log('📝 Creating new requests tracking file...');
        requests = [];
      }

      // Add new request
      requests.push({
        ...requestData,
        requestNumber: result.request.requestNumber,
        requestId: result.request.id,
        submissionStatus: 'success',
        submittedTimestamp: new Date().toISOString()
      });

      // Save updated requests
      fs.writeFileSync(requestsFile, JSON.stringify(requests, null, 2));
      console.log(`📁 Request saved to ${requestsFile}`);

      console.log('');
      console.log('🎯 Next Steps:');
      console.log('• Confirmation email will be sent to client');
      console.log('• Initial contact within 24 hours');
      console.log('• Site visit scheduled for detailed estimate');
      console.log('• Work completion within 2-3 business days');

      return result.request;
    } else {
      console.error('❌ FAILED! Request submission failed');
      console.error(`Error: ${result.error}`);
      return null;
    }
  } catch (error) {
    console.error('❌ ERROR! Exception during submission:');
    console.error(error.message);
    return null;
  }
}

// Additional example requests
async function submitMultipleRequests() {
  console.log('🔄 Submitting Multiple Service Requests');
  console.log('=======================================\n');

  const requests = [
    {
      serviceType: 'Electrical Work',
      clientName: 'Sarah Johnson',
      clientEmail: 'sarah.j@email.com',
      clientPhone: '(402) 555-5678',
      description: 'Install new ceiling fan in master bedroom. Remove old light fixture.',
      location: '456 Oak Avenue, Lincoln, NE 68510',
      priority: 'medium',
      estimatedCost: '180.00',
      additionalNotes: 'Client has ceiling fan ready to install'
    },
    {
      serviceType: 'Plumbing',
      clientName: 'Mike Wilson',
      clientEmail: 'mike.wilson@email.com',
      clientPhone: '(402) 555-9012',
      description: 'Kitchen faucet is leaking and needs replacement.',
      location: '789 Pine Street, Papillion, NE 68046',
      priority: 'high',
      estimatedCost: '120.00',
      additionalNotes: 'Water shut-off valve location is in basement'
    },
    {
      serviceType: 'Painting',
      clientName: 'Lisa Chen',
      clientEmail: 'lisa.chen@email.com',
      clientPhone: '(402) 555-3456',
      description: 'Paint accent wall in dining room. Color already selected.',
      location: '321 Elm Street, Bellevue, NE 68123',
      priority: 'low',
      estimatedCost: '95.00',
      additionalNotes: 'Paint already purchased and ready'
    }
  ];

  const tester = new JobberAPITest();
  const results = [];

  for (let i = 0; i < requests.length; i++) {
    const requestData = {
      ...requests[i],
      submittedAt: new Date().toISOString()
    };

    console.log(`📋 Request ${i + 1}: ${requestData.serviceType} for ${requestData.clientName}`);

    try {
      const result = await tester.createServiceRequest(requestData);
      if (result.success) {
        console.log(`✅ Success - Request #${result.request.requestNumber}`);
        results.push({ success: true, request: result.request });
      } else {
        console.log(`❌ Failed - ${result.error}`);
        results.push({ success: false, error: result.error });
      }
    } catch (error) {
      console.log(`❌ Error - ${error.message}`);
      results.push({ success: false, error: error.message });
    }

    console.log('');
  }

  // Summary
  const successful = results.filter(r => r.success).length;
  console.log('📊 Batch Submission Summary');
  console.log('===========================');
  console.log(`Total Requests: ${requests.length}`);
  console.log(`Successful: ${successful}`);
  console.log(`Failed: ${requests.length - successful}`);

  if (successful > 0) {
    console.log('\n🎉 Successfully submitted requests:');
    results.forEach((result, index) => {
      if (result.success) {
        console.log(`• ${requests[index].serviceType} - Request #${result.request.requestNumber}`);
      }
    });
  }

  return results;
}

// Command line interface
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args[0] === 'batch') {
    submitMultipleRequests().then(() => {
      console.log('\n🏁 Batch submission complete!');
    }).catch(error => {
      console.error('Batch submission failed:', error.message);
    });
  } else {
    submitProgrammaticRequest().then((request) => {
      if (request) {
        console.log('\n🏁 Single request submission complete!');
      } else {
        console.log('\n💥 Request submission failed!');
      }
    }).catch(error => {
      console.error('Request submission failed:', error.message);
    });
  }
}
