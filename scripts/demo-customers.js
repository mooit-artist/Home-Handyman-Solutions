#!/usr/bin/env node

/**
 * Mock Customer List Display
 * This demonstrates what the customer list would look like with real Jobber data
 */

console.log('👥 MOCK CUSTOMER LIST (Demo Data)');
console.log('=================================');
console.log('');
console.log('🔒 Note: This shows sample data. To see real customers, complete OAuth authentication.');
console.log('');

// Mock customer data based on typical Jobber structure
const mockCustomers = [
  {
    id: "client_1",
    firstName: "John",
    lastName: "Doe",
    companyName: null,
    emails: [{ address: "john.doe@example.com", primary: true }],
    phoneNumbers: [{ number: "(402) 555-1234", primary: true }],
    addresses: [{
      street: "123 Main Street",
      city: "Omaha",
      province: "NE",
      postalCode: "68102"
    }],
    createdAt: "2024-01-15T10:30:00Z",
    tags: ["Regular Customer"],
    notes: "Prefers morning appointments. Has a dog."
  },
  {
    id: "client_2",
    firstName: "Jane",
    lastName: "Smith",
    companyName: "Smith Construction LLC",
    emails: [{ address: "jane@smithconstruction.com", primary: true }],
    phoneNumbers: [{ number: "(402) 555-5678", primary: true }],
    addresses: [{
      street: "456 Oak Avenue",
      city: "Lincoln",
      province: "NE",
      postalCode: "68508"
    }],
    createdAt: "2024-02-20T14:45:00Z",
    tags: ["Commercial", "VIP"],
    notes: "Commercial accounts manager. Bulk service contracts."
  },
  {
    id: "client_3",
    firstName: "Mike",
    lastName: "Johnson",
    companyName: null,
    emails: [{ address: "mike.j@email.com", primary: true }],
    phoneNumbers: [{ number: "(402) 555-9012", primary: true }],
    addresses: [{
      street: "789 Pine Street",
      city: "Bellevue",
      province: "NE",
      postalCode: "68005"
    }],
    createdAt: "2024-03-10T09:15:00Z",
    tags: ["New Customer"],
    notes: "First-time customer. Interested in regular maintenance services."
  },
  {
    id: "client_4",
    firstName: "Sarah",
    lastName: "Williams",
    companyName: "Williams Property Management",
    emails: [{ address: "sarah@williamspm.com", primary: true }],
    phoneNumbers: [{ number: "(402) 555-3456", primary: true }],
    addresses: [{
      street: "321 Elm Drive",
      city: "Papillion",
      province: "NE",
      postalCode: "68046"
    }],
    createdAt: "2023-11-05T16:20:00Z",
    tags: ["Property Manager", "Multiple Properties"],
    notes: "Manages 15 rental properties. Requires quick response times."
  },
  {
    id: "client_5",
    firstName: "Robert",
    lastName: "Davis",
    companyName: null,
    emails: [{ address: "bob.davis@outlook.com", primary: true }],
    phoneNumbers: [{ number: "(402) 555-7890", primary: true }],
    addresses: [{
      street: "654 Maple Court",
      city: "Gretna",
      province: "NE",
      postalCode: "68028"
    }],
    createdAt: "2024-01-08T11:10:00Z",
    tags: ["Senior Discount"],
    notes: "Retired customer. Prefers afternoon appointments."
  }
];

// Display customers
mockCustomers.forEach((customer, index) => {
  const displayName = customer.companyName || `${customer.firstName} ${customer.lastName}`;
  const primaryEmail = customer.emails[0].address;
  const primaryPhone = customer.phoneNumbers[0].number;
  const address = `${customer.addresses[0].street} ${customer.addresses[0].city} ${customer.addresses[0].province} ${customer.addresses[0].postalCode}`;

  console.log(`${(index + 1).toString().padStart(3)}. ${displayName}`);
  console.log(`     📧 ${primaryEmail}`);
  console.log(`     📞 ${primaryPhone}`);
  console.log(`     🏠 ${address}`);
  console.log(`     🏷️  Tags: ${customer.tags.join(', ')}`);
  console.log(`     📝 Notes: ${customer.notes}`);
  console.log(`     📅 Created: ${new Date(customer.createdAt).toLocaleDateString()}`);
  console.log('');
});

// Summary statistics
const companiesCount = mockCustomers.filter(c => c.companyName).length;
const individualsCount = mockCustomers.length - companiesCount;

console.log('📊 CUSTOMER STATISTICS');
console.log('======================');
console.log(`Total Customers: ${mockCustomers.length}`);
console.log(`Companies: ${companiesCount}`);
console.log(`Individuals: ${individualsCount}`);
console.log(`With Email: ${mockCustomers.length}`);
console.log(`With Phone: ${mockCustomers.length}`);
console.log('');

console.log('🔐 TO ACCESS REAL CUSTOMER DATA:');
console.log('================================');
console.log('1. Complete OAuth authentication by visiting:');
console.log('   https://api.getjobber.com/api/oauth/authorize?client_id=92cf415d-f396-4bef-8807-a651d5569964');
console.log('');
console.log('2. Or run: node auth-setup.js');
console.log('');
console.log('3. Then run: node list-customers.js');
console.log('');
console.log('📱 Your Jobber Client Hub:');
console.log('   https://clienthub.getjobber.com/client_hubs/d050407f-bff1-45f6-8f57-7a3fe3c94330');
