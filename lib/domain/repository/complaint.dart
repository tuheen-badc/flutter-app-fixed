import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/ComplaintCreationModel.dart';

import '../../data/models/complaint.dart';

abstract class ComplaintRepository {
  Future<Either> submitComplaint(ComplaintCreationModel payload);
  Future<Either> getAllComplaints(ComplaintCriteria criteria);
  Future<Either> updateComplaint(int complaintId, ComplaintUpdateModel model);
}
