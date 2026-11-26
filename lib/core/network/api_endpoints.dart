class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Owner
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerVehicles = '/owner/vehicles';
  static String ownerVehicle(int id) => '/owner/vehicles/$id';
  static String ownerDailySchedule(int vehicleId) => '/owner/vehicles/$vehicleId/daily-schedule';
  static String ownerPickupRequests(int vehicleId) => '/owner/vehicles/$vehicleId/pickup-requests';
  static String ownerCancelPickupRequest(int requestId) => '/owner/pickup-requests/$requestId/cancel';

  // Employee
  static const String employeeQueue = '/employee/queue';
  static const String employeeQueueSummary = '/employee/queue/summary';
  static const String employeeVehicles = '/employee/vehicles';
  static String employeeVehicleSpot(int vehicleId) => '/employee/vehicles/$vehicleId/spot';
  static String employeeVehicleStatus(int vehicleId) => '/employee/vehicles/$vehicleId/status';
}
