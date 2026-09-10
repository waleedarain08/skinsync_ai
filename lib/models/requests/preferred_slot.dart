class  PreferredSlot {
  final int date;
  final int time;

  PreferredSlot({required this.date, required this.time});

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
    };
  }
}
