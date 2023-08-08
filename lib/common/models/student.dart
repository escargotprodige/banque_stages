import 'dart:math';

import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';

enum Program {
  fpt,
  fms;

  @override
  String toString() {
    switch (this) {
      case Program.fpt:
        return 'FPT';
      case Program.fms:
        return 'FMS';
    }
  }
}

class Student extends Person {
  final String photo;
  late final Widget avatar;

  final String teacherId;
  final Program program;
  final String group;

  final Person contact;
  final String contactLink;

  Student({
    super.id,
    required super.firstName,
    super.middleName,
    required super.lastName,
    required super.dateBirth,
    super.phone,
    required super.email,
    required super.address,
    String? photo,
    required this.teacherId,
    required this.program,
    required this.group,
    required this.contact,
    required this.contactLink,
  }) : photo = photo ?? Random().nextInt(0x00FF00).toString() {
    avatar = CircleAvatar(
        backgroundColor: Color(int.parse(this.photo)).withAlpha(255));
  }

  bool hasActiveInternship(BuildContext context) {
    final internships = InternshipsProvider.of(context, listen: false);
    for (final internship in internships) {
      if (internship.isActive && internship.studentId == id) return true;
    }
    return false;
  }

  Student.fromSerialized(map)
      : photo = map['photo'],
        avatar = CircleAvatar(
            backgroundColor: Color(int.parse(map['photo'])).withAlpha(255)),
        teacherId = map['teacherId'],
        program = Program.values[map['program']],
        group = map['group'],
        contact = Person.fromSerialized(map['contact']),
        contactLink = map['contactLink'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return super.serializedMap()
      ..addAll({
        'photo': photo,
        'teacherId': teacherId,
        'program': program.index,
        'group': group,
        'contact': contact.serialize(),
        'contactLink': contactLink,
      });
  }

  @override
  Student copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    DateTime? dateBirth,
    PhoneNumber? phone,
    String? email,
    Address? address,
    String? teacherId,
    Program? program,
    String? group,
    Person? contact,
    String? contactLink,
    String? id,
  }) =>
      Student(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        dateBirth: dateBirth ?? this.dateBirth,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        teacherId: teacherId ?? this.teacherId,
        program: program ?? this.program,
        group: group ?? this.group,
        contact: contact ?? this.contact,
        contactLink: contactLink ?? this.contactLink,
      );

  @override
  Student deepCopy() {
    return Student(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      dateBirth: dateBirth == null
          ? null
          : DateTime(dateBirth!.year, dateBirth!.month, dateBirth!.day),
      phone: phone.deepCopy(),
      email: email,
      address: address?.deepCopy(),
      contact: contact.deepCopy(),
      contactLink: contactLink,
      group: group,
      program: program,
      teacherId: teacherId,
    );
  }
}
