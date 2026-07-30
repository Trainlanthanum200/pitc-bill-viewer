// Model representing a saved electricity account reference.

class SavedRef {
  final String id;
  final String label;
  final String refNo;
  final String discoCode; // e.g. "mepcobill", "lescobill"

  SavedRef({
    required this.id,
    required this.label,
    required this.refNo,
    required this.discoCode,
  });

  Map<String, dynamic> toJson() =>
      {"id": id, "label": label, "refNo": refNo, "discoCode": discoCode};

  factory SavedRef.fromJson(Map<String, dynamic> json) => SavedRef(
        id: json["id"],
        label: json["label"],
        refNo: json["refNo"],
        discoCode: json["discoCode"] ?? "mepcobill",
      );
}

