class Client {
  String? name;
  String? birth_date;
  String? cpf;
  String? RG;
  String? tel;
  String? email;
  int? id;

  Client(this.name, this.birth_date, this.cpf, this.RG, this.tel, this.email,
      {this.id});

  setId(int id) {
    this.id = id;
  }

  Map<String, dynamic> toMap() {
    return {
      'client_id': id,
      'name': name,
      'birth_date': birth_date,
      'cpf': cpf,
      'RG': RG,
      'tel': tel,
      'email': email,
    };
  }
}
