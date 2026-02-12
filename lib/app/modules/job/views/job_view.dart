import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/job_controller.dart';

class JobView extends GetView<JobController> {
  const JobView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
      ),
      body: const Center(
        child: Text('Job Screen'),
      ),
    );
  }
}


