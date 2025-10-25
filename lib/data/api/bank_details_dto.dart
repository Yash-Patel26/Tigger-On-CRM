class BankDetailsDto {
  BankDetailsDto({
    this.accountHolderName,
    this.accountNumber,
    this.ifsc,
    this.bankName,
    this.branch,
    this.upiId,
  });

  final String? accountHolderName;
  final String? accountNumber;
  final String? ifsc;
  final String? bankName;
  final String? branch;
  final String? upiId;

  factory BankDetailsDto.fromJson(Map<String, dynamic> json) => BankDetailsDto(
    accountHolderName: json['accountHolderName'] as String?,
    accountNumber: json['accountNumber'] as String?,
    ifsc: json['ifsc'] as String?,
    bankName: json['bankName'] as String?,
    branch: json['branch'] as String?,
    upiId: json['upiId'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (accountHolderName != null) 'accountHolderName': accountHolderName,
    if (accountNumber != null) 'accountNumber': accountNumber,
    if (ifsc != null) 'ifsc': ifsc,
    if (bankName != null) 'bankName': bankName,
    if (branch != null) 'branch': branch,
    if (upiId != null) 'upiId': upiId,
  };
}
