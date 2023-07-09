import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gravity/consts.dart';
import 'package:gravity/bloc/bloc_data_status.dart';
import 'package:gravity/ui/widget/error_dialog.dart';
import 'package:gravity/ui/dialog/choose_location_dialog.dart';

import 'beacon_create_cubit.dart';

class BeaconCreateScreen extends StatelessWidget {
  static const _padding = SizedBox(height: 20);

  const BeaconCreateScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => BeaconCreateCubit(),
        child: BlocConsumer<BeaconCreateCubit, BeaconCreateState>(
          listener: (context, state) {
            switch (state.status) {
              case BlocDataStatus.hasData:
                Navigator.of(context).pop();
              case BlocDataStatus.hasError:
                showDialog<void>(
                  context: context,
                  builder: (_) => ErrorDialog(error: state.error),
                );
              default:
            }
          },
          builder: (context, state) {
            final cubit = context.read<BeaconCreateCubit>();
            return Scaffold(
              appBar: AppBar(
                actions: [
                  TextButton(
                    onPressed: state.isValid ? cubit.save : null,
                    child: const Text('Done'),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              body: ListView(
                key: const Key('NewBeaconListView'),
                padding: const EdgeInsets.all(20),
                children: [
                  // Title
                  TextField(
                    key: const Key('NewBeaconTitle'),
                    decoration: const InputDecoration(
                      hintText: 'Beacon title',
                    ),
                    keyboardType: TextInputType.text,
                    maxLength: titleMaxLength,
                    onChanged: cubit.setTitle,
                  ),
                  // Description
                  TextField(
                    key: const Key('NewBeaconDescription'),
                    decoration: const InputDecoration(
                      hintText: 'Description',
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLength: descriptionLength,
                    maxLines: null,
                    onChanged: cubit.setDescription,
                  ),
                  // Image
                  TextField(
                    key: const Key('NewBeaconImage'),
                    controller: cubit.imageController,
                    decoration: InputDecoration(
                      hintText: 'Attach image',
                      suffixIcon: state.imagePath.isEmpty
                          ? const Icon(Icons.add_a_photo_rounded)
                          : IconButton(
                              onPressed: cubit.clearImage,
                              icon: const Icon(Icons.cancel_rounded),
                            ),
                    ),
                    readOnly: true,
                    onTap: cubit.setImage,
                  ),
                  // Location
                  _padding,
                  TextField(
                    key: const Key('NewBeaconLocation'),
                    controller: cubit.locationController,
                    decoration: InputDecoration(
                      hintText: 'Add location',
                      suffixIcon: state.coordinates == null
                          ? const Icon(Icons.add_location_rounded)
                          : IconButton(
                              onPressed: cubit.clearCoords,
                              icon: const Icon(Icons.cancel_rounded),
                            ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final point = await ChooseLocationDialog.show(
                        context: context,
                        center: state.coordinates ?? cubit.myCoords,
                      );
                      if (context.mounted) await cubit.setCoords(point);
                    },
                  ),
                  _padding,
                  // Time
                  TextField(
                    key: const Key('NewBeaconTime'),
                    controller: cubit.dateRangeController,
                    decoration: InputDecoration(
                      hintText: 'Set time',
                      suffixIcon: state.dateRange == null
                          ? const Icon(Icons.date_range_rounded)
                          : IconButton(
                              onPressed: cubit.clearDateRange,
                              icon: const Icon(Icons.cancel_rounded),
                            ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final now = DateTime.now();
                      cubit.setDateRange(
                        await showDateRangePicker(
                          context: context,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 365)),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                        ),
                      );
                    },
                  ),
                  // Image
                  Container(
                    decoration: BoxDecoration(
                      border: state.imagePath.isEmpty
                          ? Border.all(color: Colors.black12)
                          : null,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 48),
                    child: state.imagePath.isEmpty
                        ? const Icon(Icons.photo_outlined, size: 200)
                        : Image.file(
                            File(state.imagePath),
                            fit: BoxFit.fitWidth,
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      );
}