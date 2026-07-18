import '../models/student.dart';

class StudentFilter {
  static List<Student> apply(
    List<Student> students, {
    required String query,
    required String filter,
  }) {
    var result = students
        .where(
          (student) => '${student.name} ${student.phone} ${student.seat}'
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .where(
          (student) =>
              filter == 'All' ||
              filter == 'Full Time' &&
                  student.membership == MembershipType.fullTime ||
              filter == 'Half Time' &&
                  student.membership == MembershipType.halfTime ||
              filter == 'Expiring' &&
                  student.payment == PaymentStatus.pending ||
              filter == _capitalize(student.payment.name),
        )
        .toList();
    if (filter == 'Newest') result = result.reversed.toList();
    if (filter == 'Oldest') result = result.toList();
    return result;
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
