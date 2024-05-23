import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnDevicesSelected = void Function(List<twin.Device> devices);

class DeviceFieldDropdown extends StatefulWidget {
  final List<String> selectedDevices;
  final OnDevicesSelected onDevicesSelected;

  const DeviceFieldDropdown({
    super.key,
    required this.selectedDevices,
    required this.onDevicesSelected,
  });

  @override
  State<DeviceFieldDropdown> createState() => _DeviceFieldDropdownState();
}

class _DeviceFieldDropdownState extends BaseState<DeviceFieldDropdown> {
  final List<DropdownMenuEntry<twin.Device>> _dropdownMenuEntries = [];
  final List<twin.Device> _selectedDevices = [];

  @override
  Widget build(BuildContext context) {
    if (_dropdownMenuEntries.isEmpty) {
      return const Icon(Icons.hourglass_bottom);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black38),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonFormField<twin.Device>(
        items: _dropdownMenuEntries.map((entry) {
          return DropdownMenuItem<twin.Device>(
            value: entry.value,
            child: CheckboxListTile(
              title: Text(entry.label),
              value: _selectedDevices.contains(entry.value),
              onChanged: (isSelected) {
                setState(() {
                  if (isSelected == true) {
                    _selectedDevices.add(entry.value!);
                  } else {
                    _selectedDevices.remove(entry.value);
                  }
                  widget.onDevicesSelected(_selectedDevices);
                });
              },
            ),
          );
        }).toList(),
        onChanged: (value) {},
        isExpanded: true,
      ),
    );
  }

  Future load() async {
    if (loading) return;
    loading = true;
    _dropdownMenuEntries.clear();
    await execute(() async {
      var pRes = await TwinnedSession.instance.twin.listDevices(
        apikey: TwinnedSession.instance.authToken,
        body: const twin.ListReq(page: 0, size: 100),
      );
      if (validateResponse(pRes)) {
        List<String> names = [];
        for (var dev in pRes.body!.values!) {
          if (widget.selectedDevices.contains(dev.name)) {
            _selectedDevices.add(dev);
          }
          if (names.contains(dev.name)) continue;
          _dropdownMenuEntries.add(DropdownMenuEntry<twin.Device>(
            label: dev.name,
            value: dev,
          ));
          names.add(dev.name);
        }
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}
