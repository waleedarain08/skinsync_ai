
class ChangePaymentStatusRequest  {
  final String paymentStatus;

  ChangePaymentStatusRequest({
   
    required this.paymentStatus,
  });


  Map<String, dynamic> toJson() {
    return {
      
      'payment_status': paymentStatus,
    };
  }

  factory ChangePaymentStatusRequest.fromJson(Map<String, dynamic> json) {
    return ChangePaymentStatusRequest(
  
      paymentStatus: json['payment_status'],
    );
  }
}