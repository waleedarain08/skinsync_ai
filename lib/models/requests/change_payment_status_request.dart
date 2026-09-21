
class ChangePaymentStatusRequest  {
  final String paymentStatus;

  ChangePaymentStatusRequest({
   
    required this.paymentStatus,
  });


  Map<String, dynamic> toJson() {
    return {
      'status': paymentStatus,
    };
  }

  factory ChangePaymentStatusRequest.fromJson(Map<String, dynamic> json) {
    return ChangePaymentStatusRequest(
  
      paymentStatus: json['payment_status'],
    );
  }
}