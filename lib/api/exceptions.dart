class TimedOutException implements Exception {
  String cause = 'Erreur de connecection avec le seurver';

  TimedOutException(cause);
}
