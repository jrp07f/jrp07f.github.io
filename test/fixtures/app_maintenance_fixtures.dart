class AppMaintenanceFixtures {
  static String downloadResponse(
          {String alertStart = '2020-04-15T19:06:37',
          String maintenanceStart = '2020-04-16T19:06:46',
          String maintenanceEnd = '2020-04-16T20:06:50',
          String title = 'title',
          String body = 'body'}) =>
      """[
  {"id": 99, "alert_start": "$alertStart", "maintenance_start": "$maintenanceStart", "maintenance_end": "$maintenanceEnd", "title": "$title", "body": "$body"}
  ]
  """;
}
