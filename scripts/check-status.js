#!/usr/bin/env node

/**
 * Request Status Checker
 * Monitor and manage submitted service requests
 */

const fs = require('fs');
const path = require('path');
const JobberAPITest = require('./test-jobber-api.js');

class RequestStatusChecker {
  constructor() {
    this.tester = new JobberAPITest();
    this.requestsFile = '../submitted-requests.json';
    this.statusFile = '../request-status-log.json';
  }

  /**
   * Load all submitted requests
   */
  loadRequests() {
    try {
      if (fs.existsSync(this.requestsFile)) {
        const data = fs.readFileSync(this.requestsFile, 'utf8');
        return JSON.parse(data);
      }
      return [];
    } catch (error) {
      console.error('Error loading requests:', error.message);
      return [];
    }
  }

  /**
   * Load status history
   */
  loadStatusHistory() {
    try {
      if (fs.existsSync(this.statusFile)) {
        const data = fs.readFileSync(this.statusFile, 'utf8');
        return JSON.parse(data);
      }
      return [];
    } catch (error) {
      console.error('Error loading status history:', error.message);
      return [];
    }
  }

  /**
   * Save status update
   */
  saveStatusUpdate(requestId, oldStatus, newStatus, notes = '') {
    const statusHistory = this.loadStatusHistory();

    const update = {
      requestId,
      requestNumber: this.getRequestNumber(requestId),
      oldStatus,
      newStatus,
      notes,
      updatedAt: new Date().toISOString(),
      updatedBy: 'system'
    };

    statusHistory.push(update);

    try {
      fs.writeFileSync(this.statusFile, JSON.stringify(statusHistory, null, 2));
      return true;
    } catch (error) {
      console.error('Error saving status update:', error.message);
      return false;
    }
  }

  /**
   * Get request number by ID
   */
  getRequestNumber(requestId) {
    const requests = this.loadRequests();
    const request = requests.find(r => r.requestId === requestId);
    return request ? request.requestNumber : 'Unknown';
  }

  /**
   * Check status of a specific request
   */
  async checkRequestStatus(requestId) {
    console.log(`🔍 Checking Status for Request ID: ${requestId}`);
    console.log('==========================================');

    const requests = this.loadRequests();
    const request = requests.find(r => r.requestId === requestId);

    if (!request) {
      console.log('❌ Request not found');
      return null;
    }

    // Simulate status check (in real implementation, this would query Jobber API)
    const possibleStatuses = ['pending', 'scheduled', 'in_progress', 'completed', 'cancelled'];
    const currentStatus = possibleStatuses[Math.floor(Math.random() * possibleStatuses.length)];

    console.log(`📋 Request Details:`);
    console.log(`   Request #: ${request.requestNumber}`);
    console.log(`   Service: ${request.serviceType}`);
    console.log(`   Client: ${request.clientName}`);
    console.log(`   Location: ${request.location}`);
    console.log(`   Priority: ${request.priority.toUpperCase()}`);
    console.log(`   Submitted: ${new Date(request.submittedAt).toLocaleString()}`);
    console.log(`   Current Status: ${currentStatus.toUpperCase()}`);

    // Show status timeline
    const statusHistory = this.loadStatusHistory().filter(h => h.requestId === requestId);
    if (statusHistory.length > 0) {
      console.log('\n📅 Status History:');
      statusHistory.forEach(update => {
        console.log(`   ${new Date(update.updatedAt).toLocaleString()}: ${update.oldStatus} → ${update.newStatus}`);
        if (update.notes) {
          console.log(`      Notes: ${update.notes}`);
        }
      });
    }

    // Estimated completion
    const estimatedCompletion = this.getEstimatedCompletion(currentStatus, request.priority);
    if (estimatedCompletion) {
      console.log(`\n⏰ Estimated Completion: ${estimatedCompletion}`);
    }

    return {
      request,
      currentStatus,
      statusHistory,
      estimatedCompletion
    };
  }

  /**
   * Get estimated completion time
   */
  getEstimatedCompletion(status, priority) {
    const now = new Date();
    let days = 0;

    switch (status) {
      case 'pending':
        days = priority === 'urgent' ? 1 : priority === 'high' ? 2 : priority === 'medium' ? 3 : 7;
        break;
      case 'scheduled':
        days = priority === 'urgent' ? 1 : 2;
        break;
      case 'in_progress':
        days = 1;
        break;
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        days = 3;
    }

    const completionDate = new Date(now.getTime() + (days * 24 * 60 * 60 * 1000));
    return completionDate.toLocaleDateString();
  }

  /**
   * List all requests with their current status
   */
  async listAllRequests() {
    console.log('📋 All Service Requests');
    console.log('=======================\n');

    const requests = this.loadRequests();

    if (requests.length === 0) {
      console.log('📭 No requests found');
      return [];
    }

    const requestsWithStatus = [];

    for (const request of requests) {
      // Simulate current status
      const possibleStatuses = ['pending', 'scheduled', 'in_progress', 'completed', 'cancelled'];
      const currentStatus = possibleStatuses[Math.floor(Math.random() * possibleStatuses.length)];

      const statusEmoji = this.getStatusEmoji(currentStatus);
      const priorityEmoji = this.getPriorityEmoji(request.priority);

      console.log(`${statusEmoji} ${request.requestNumber} - ${request.serviceType}`);
      console.log(`   Client: ${request.clientName} | Priority: ${priorityEmoji} ${request.priority.toUpperCase()}`);
      console.log(`   Status: ${currentStatus.toUpperCase()} | Submitted: ${new Date(request.submittedAt).toLocaleDateString()}`);
      console.log(`   Location: ${request.location}`);
      console.log('');

      requestsWithStatus.push({
        ...request,
        currentStatus
      });
    }

    // Summary
    const statusCounts = this.getStatusCounts(requestsWithStatus);
    console.log('📊 Status Summary:');
    Object.entries(statusCounts).forEach(([status, count]) => {
      const emoji = this.getStatusEmoji(status);
      console.log(`   ${emoji} ${status.toUpperCase()}: ${count}`);
    });

    return requestsWithStatus;
  }

  /**
   * Get status emoji
   */
  getStatusEmoji(status) {
    const emojis = {
      pending: '⏳',
      scheduled: '📅',
      in_progress: '🔨',
      completed: '✅',
      cancelled: '❌'
    };
    return emojis[status] || '❓';
  }

  /**
   * Get priority emoji
   */
  getPriorityEmoji(priority) {
    const emojis = {
      low: '🟢',
      medium: '🟡',
      high: '🟠',
      urgent: '🔴'
    };
    return emojis[priority] || '⚪';
  }

  /**
   * Count requests by status
   */
  getStatusCounts(requests) {
    return requests.reduce((counts, request) => {
      counts[request.currentStatus] = (counts[request.currentStatus] || 0) + 1;
      return counts;
    }, {});
  }

  /**
   * Filter requests by status
   */
  async filterByStatus(targetStatus) {
    console.log(`🔍 Requests with Status: ${targetStatus.toUpperCase()}`);
    console.log('==========================================\n');

    const allRequests = await this.listAllRequests();
    const filteredRequests = allRequests.filter(r => r.currentStatus === targetStatus);

    if (filteredRequests.length === 0) {
      console.log(`📭 No requests found with status: ${targetStatus}`);
      return [];
    }

    console.log(`Found ${filteredRequests.length} request(s) with status: ${targetStatus.toUpperCase()}\n`);

    filteredRequests.forEach(request => {
      console.log(`📋 ${request.requestNumber} - ${request.serviceType}`);
      console.log(`   Client: ${request.clientName}`);
      console.log(`   Priority: ${request.priority.toUpperCase()}`);
      console.log(`   Submitted: ${new Date(request.submittedAt).toLocaleDateString()}`);
      console.log('');
    });

    return filteredRequests;
  }

  /**
   * Update request status manually
   */
  async updateRequestStatus(requestId, newStatus, notes = '') {
    console.log(`🔄 Updating Request Status`);
    console.log('==========================');

    const requests = this.loadRequests();
    const requestIndex = requests.findIndex(r => r.requestId === requestId);

    if (requestIndex === -1) {
      console.log('❌ Request not found');
      return false;
    }

    const request = requests[requestIndex];
    const oldStatus = request.currentStatus || 'pending';

    // Update status
    requests[requestIndex].currentStatus = newStatus;
    requests[requestIndex].lastUpdated = new Date().toISOString();

    try {
      // Save updated requests
      fs.writeFileSync(this.requestsFile, JSON.stringify(requests, null, 2));

      // Log status change
      this.saveStatusUpdate(requestId, oldStatus, newStatus, notes);

      console.log(`✅ Status updated successfully`);
      console.log(`   Request: ${request.requestNumber}`);
      console.log(`   Old Status: ${oldStatus}`);
      console.log(`   New Status: ${newStatus}`);
      if (notes) {
        console.log(`   Notes: ${notes}`);
      }

      return true;
    } catch (error) {
      console.error('❌ Error updating status:', error.message);
      return false;
    }
  }

  /**
   * Get requests by priority
   */
  async getRequestsByPriority(priority) {
    console.log(`🚨 ${priority.toUpperCase()} Priority Requests`);
    console.log('========================================\n');

    const requests = this.loadRequests();
    const priorityRequests = requests.filter(r => r.priority === priority);

    if (priorityRequests.length === 0) {
      console.log(`📭 No ${priority} priority requests found`);
      return [];
    }

    priorityRequests.forEach(request => {
      const statusEmoji = this.getStatusEmoji(request.currentStatus || 'pending');
      console.log(`${statusEmoji} ${request.requestNumber} - ${request.serviceType}`);
      console.log(`   Client: ${request.clientName}`);
      console.log(`   Submitted: ${new Date(request.submittedAt).toLocaleDateString()}`);
      console.log(`   Description: ${request.description}`);
      console.log('');
    });

    return priorityRequests;
  }

  /**
   * Generate status report
   */
  async generateReport() {
    console.log('📊 Service Request Status Report');
    console.log('================================\n');

    const requests = this.loadRequests();

    if (requests.length === 0) {
      console.log('📭 No requests to report on');
      return;
    }

    // Overall stats
    console.log(`📈 Overall Statistics:`);
    console.log(`   Total Requests: ${requests.length}`);
    console.log(`   Date Range: ${new Date(Math.min(...requests.map(r => new Date(r.submittedAt)))).toLocaleDateString()} - ${new Date(Math.max(...requests.map(r => new Date(r.submittedAt)))).toLocaleDateString()}`);

    // Service type breakdown
    const serviceTypes = requests.reduce((types, request) => {
      types[request.serviceType] = (types[request.serviceType] || 0) + 1;
      return types;
    }, {});

    console.log('\n🔧 Service Types:');
    Object.entries(serviceTypes).forEach(([type, count]) => {
      console.log(`   ${type}: ${count}`);
    });

    // Priority breakdown
    const priorities = requests.reduce((prios, request) => {
      prios[request.priority] = (prios[request.priority] || 0) + 1;
      return prios;
    }, {});

    console.log('\n⚡ Priority Distribution:');
    Object.entries(priorities).forEach(([priority, count]) => {
      const emoji = this.getPriorityEmoji(priority);
      console.log(`   ${emoji} ${priority.toUpperCase()}: ${count}`);
    });

    // Recent activity
    const recentRequests = requests
      .sort((a, b) => new Date(b.submittedAt) - new Date(a.submittedAt))
      .slice(0, 5);

    console.log('\n🕒 Recent Requests:');
    recentRequests.forEach(request => {
      console.log(`   ${request.requestNumber} - ${request.serviceType} (${new Date(request.submittedAt).toLocaleDateString()})`);
    });

    console.log('\n📅 Report Generated:', new Date().toLocaleString());
  }
}

// Export the class
module.exports = RequestStatusChecker;

// Command line interface
if (require.main === module) {
  const checker = new RequestStatusChecker();
  const args = process.argv.slice(2);

  async function runCommand() {
    try {
      if (args.length === 0) {
        // Default: list all requests
        await checker.listAllRequests();
      } else {
        const command = args[0];

        switch (command) {
          case 'list':
            await checker.listAllRequests();
            break;

          case 'check':
            if (args[1]) {
              await checker.checkRequestStatus(args[1]);
            } else {
              console.log('❌ Please provide a request ID');
              console.log('Usage: node check-status.js check <request-id>');
            }
            break;

          case 'status':
            if (args[1]) {
              await checker.filterByStatus(args[1]);
            } else {
              console.log('❌ Please provide a status');
              console.log('Usage: node check-status.js status <pending|scheduled|in_progress|completed|cancelled>');
            }
            break;

          case 'priority':
            if (args[1]) {
              await checker.getRequestsByPriority(args[1]);
            } else {
              console.log('❌ Please provide a priority level');
              console.log('Usage: node check-status.js priority <low|medium|high|urgent>');
            }
            break;

          case 'update':
            if (args[1] && args[2]) {
              const notes = args[3] || '';
              await checker.updateRequestStatus(args[1], args[2], notes);
            } else {
              console.log('❌ Please provide request ID and new status');
              console.log('Usage: node check-status.js update <request-id> <new-status> [notes]');
            }
            break;

          case 'report':
            await checker.generateReport();
            break;

          case 'help':
            console.log('🔍 Request Status Checker Commands:');
            console.log('===================================');
            console.log('  list                          - List all requests');
            console.log('  check <request-id>           - Check specific request status');
            console.log('  status <status-name>         - Filter by status');
            console.log('  priority <priority-level>    - Filter by priority');
            console.log('  update <id> <status> [notes] - Update request status');
            console.log('  report                       - Generate status report');
            console.log('  help                         - Show this help');
            break;

          default:
            console.log(`❌ Unknown command: ${command}`);
            console.log('Use "node check-status.js help" for available commands');
        }
      }
    } catch (error) {
      console.error('❌ Error:', error.message);
    }
  }

  runCommand();
}
