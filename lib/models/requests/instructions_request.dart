class InstructionsRequest {
  final int appointmentId;
  final List<int> sessionIds;

  InstructionsRequest({
    required this.appointmentId,
    required this.sessionIds,
  });

  Map<String, dynamic> toJson() {
    return {'appointment_id': appointmentId, 'session_ids': sessionIds};
  }
}
