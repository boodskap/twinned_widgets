import 'package:flutter/material.dart';
import 'package:select2dot1/select2dot1.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnDevicesSelected = void Function(twin.Device? device);

class MultiDeviceDropdown extends StatefulWidget {
  final String? selectedDevice;
  final OnDevicesSelected onDevicesSelected;

  const MultiDeviceDropdown({
    super.key,
    required this.selectedDevice,
    required this.onDevicesSelected,
  });

  @override
  State<MultiDeviceDropdown> createState() => _MultiDeviceDropdownState();
}

class _MultiDeviceDropdownState extends State<MultiDeviceDropdown> {
  twin.Device? _selectedDevice;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SingleCategoryModel>>(
      future: _search(''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Select2dot1(
            selectDataController: SelectDataController(
              data: snapshot.data ?? [],
            ),
            pillboxContentMultiSettings:
                const PillboxContentMultiSettings(pillboxOverload: 100),
            onChanged: (selected) {
              setState(() {
                _selectedDevice = selected as twin.Device?;
              });
              widget.onDevicesSelected(_selectedDevice);
            },
          );
        }
      },
    );
  }

  Future<List<SingleCategoryModel>> _search(String keyword) async {
    List<SingleCategoryModel> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchDevices(
        apikey: TwinnedSession.instance.authToken,
        body: twin.SearchReq(search: keyword, page: 0, size: 25),
      );
      if (pRes.body != null) {
        for (var entity in pRes.body!.values!) {
          items.add(SingleCategoryModel(
            singleItemCategoryList: [
              SingleItemCategoryModel(
                  nameSingleItem:
                      '${entity.name}, SN:${entity.deviceId} ${entity.description}')
            ],
          ));
        }
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (null == widget.selectedDevice || widget.selectedDevice!.isEmpty) return;
    try {
      var eRes = await TwinnedSession.instance.twin.getDevice(
        apikey: TwinnedSession.instance.authToken,
        deviceId: widget.selectedDevice!,
      );
      if (eRes != null && eRes.body != null) {
        setState(() {
          _selectedDevice = eRes.body!.entity;
        });
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }
}
