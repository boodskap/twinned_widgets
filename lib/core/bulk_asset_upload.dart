import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned_widgets/core/asset_model_dropdown.dart';
import 'package:twinned_widgets/core/device_model_dropdown.dart';
import 'package:twinned_widgets/core/facility_dropdown.dart';
import 'package:twinned_widgets/core/floor_dropdown.dart';
import 'package:twinned_widgets/core/multi_client_dropdown.dart';
import 'package:twinned_widgets/core/multi_role_dropdown.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/twin_image_helper.dart';

class BulkAssetUpload extends StatefulWidget {
  final String? selectedPremise;
  final String? selectedFacility;
  final String? selectedFloor;
  final String? selectedAssetModel;
  final String? selectedDeviceModel;

  const BulkAssetUpload(
      {super.key,
      this.selectedPremise,
      this.selectedFacility,
      this.selectedFloor,
      this.selectedAssetModel,
      this.selectedDeviceModel});

  @override
  State<BulkAssetUpload> createState() => _BulkAssetUploadState();
}

class _BulkAssetUploadState extends BaseState<BulkAssetUpload> {
  static const TextStyle labelStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black);

  String? selectedPremise;
  String? selectedFacility;
  String? selectedFloor;
  String? selectedAssetModel;
  String? selectedDeviceModel;
  List<String>? selectedRoles;
  List<String>? selectedClients;

  @override
  void initState() {
    selectedPremise = widget.selectedPremise;
    selectedFacility = widget.selectedFacility;
    selectedFloor = widget.selectedFloor;
    selectedAssetModel = widget.selectedAssetModel;
    selectedDeviceModel = widget.selectedDeviceModel;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Premise',
                    style: labelStyle,
                  ),
                ),
                divider(horizontal: true),
                Expanded(
                  flex: 3,
                  child: PremiseDropdown(
                      selectedItem: selectedPremise,
                      onPremiseSelected: (selected) {
                        _selectPremise(selected);
                      }),
                )
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Facility',
                    style: labelStyle,
                  ),
                ),
                divider(horizontal: true),
                Expanded(
                  flex: 3,
                  child: FacilityDropdown(
                      selectedItem: selectedFacility,
                      selectedPremise: selectedPremise,
                      onFacilitySelected: (selected) {
                        _selectFacility(selected);
                      }),
                )
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Floor',
                    style: labelStyle,
                  ),
                ),
                divider(horizontal: true),
                Expanded(
                  flex: 3,
                  child: FloorDropdown(
                      selectedItem: selectedFloor,
                      selectedPremise: selectedPremise,
                      selectedFacility: selectedFacility,
                      onFloorSelected: (selected) {
                        _selectFloor(selected);
                      }),
                )
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Asset Type',
                    style: labelStyle,
                  ),
                ),
                divider(horizontal: true),
                Expanded(
                  flex: 3,
                  child: AssetModelDropdown(
                      selectedItem: selectedAssetModel,
                      onAssetModelSelected: (selected) {
                        _selectAssetModel(selected);
                      }),
                )
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Device Type',
                    style: labelStyle,
                  ),
                ),
                divider(horizontal: true),
                Expanded(
                  flex: 3,
                  child: DeviceModelDropdown(
                      selectedItem: selectedDeviceModel,
                      onDeviceModelSelected: (selected) {
                        _selectDeviceModel(selected);
                      }),
                )
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Roles',
                    style: labelStyle,
                  ),
                ),
                divider(horizontal: true),
                Expanded(
                  flex: 3,
                  child: MultiRoleDropdown(
                      selectedItems: selectedRoles ?? [],
                      onRolesSelected: (selected) {
                        _selectRoles(selected);
                      }),
                )
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Clients',
                    style: labelStyle,
                  ),
                ),
                divider(horizontal: true),
                Expanded(
                  flex: 3,
                  child: MultiClientDropdown(
                      allowDuplicates: false,
                      selectedItems: selectedClients ?? [],
                      onClientsSelected: (selected) {
                        _selectClients(selected);
                      }),
                )
              ],
            ),
            divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const BusyIndicator(),
                divider(horizontal: true),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cancel,
                        ),
                        divider(horizontal: true, width: 4),
                        const Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                divider(horizontal: true),
                ElevatedButton(
                    onPressed: !_canUpload()
                        ? null
                        : () {
                            _bulkImport();
                          },
                    child: Row(
                      children: [
                        Icon(
                          Icons.upload,
                          color: _canUpload() ? Colors.blue : Colors.grey,
                        ),
                        divider(horizontal: true, width: 4),
                        const Text(
                          'Upload File',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _selectPremise(twin.Premise? entity) {
    setState(() {
      selectedPremise = entity?.id;
    });
  }

  void _selectFacility(twin.Facility? entity) {
    setState(() {
      selectedFacility = entity?.id;
    });
  }

  void _selectFloor(twin.Floor? entity) {
    setState(() {
      selectedFloor = entity?.id;
    });
  }

  void _selectAssetModel(twin.AssetModel? entity) {
    setState(() {
      selectedAssetModel = entity?.id;
    });
  }

  void _selectDeviceModel(twin.DeviceModel? entity) {
    setState(() {
      selectedDeviceModel = entity?.id;
    });
  }

  void _selectRoles(List<twin.Role>? entities) {
    setState(() {
      if (null != entities) {
        selectedRoles = entities!.map((role) {
          return role.id;
        }).toList();
      } else {
        selectedRoles = null;
      }
    });
  }

  void _selectClients(List<twin.Client>? entities) {
    setState(() {
      if (null != entities) {
        selectedClients = entities!.map((client) {
          return client.id;
        }).toList();
      } else {
        selectedClients = null;
      }
    });
  }

  bool _canUpload() {
    return null != selectedPremise &&
        null != selectedFacility &&
        null != selectedFloor &&
        null != selectedAssetModel &&
        null != selectedDeviceModel;
  }

  void _close() {
    Navigator.pop(context);
  }

  Future _bulkImport() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var file = await TwinImageHelper.pickFile(
          allowedExtensions: ['txt', 'TXT', 'csv', 'CSV']);
      if (null == file) return null;

      var res = await TwinImageHelper.uploadAssetBulkUpload(file,
          assetModelId: selectedAssetModel!,
          clientIds: selectedClients ?? [],
          deviceModelId: selectedDeviceModel!,
          facilityId: selectedFacility!,
          floorId: selectedFloor!,
          premiseId: selectedPremise!,
          roleIds: selectedRoles ?? []);

      if (null != res) {
        if (res.ok) {
          _close();
          await alert('Success', '${res.total} Assets imported successfully');
        } else {
          if (res.failures.isNotEmpty) {
            await alert('Failure', '${res.failed} / ${res.total} imported');
          } else {
            await alert('Upload Failed', res.msg ?? 'Unknown failure');
          }
        }
      } else {
        await alert('Failure', 'Unable to upload, unknown failure');
      }
    });

    loading = false;
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}
