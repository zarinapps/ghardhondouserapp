import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/panaroma_image_view.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:ebroker/utils/imagePicker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AddPropertyDetails extends StatefulWidget {
  const AddPropertyDetails({super.key, this.propertyDetails, this.properties});

  final Map<dynamic, dynamic>? propertyDetails;
  final Map<dynamic, dynamic>? properties;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (context) {
        return AddPropertyDetails(
          propertyDetails: arguments?['details'] as Map<String, dynamic>?,
          properties: arguments?['properties'] as Map<String, dynamic>?,
        );
      },
    );
  }

  @override
  State<AddPropertyDetails> createState() => _AddPropertyDetailsState();
}

class _AddPropertyDetailsState extends State<AddPropertyDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late PropertyModel? property = getEditPropertyData(
    widget.propertyDetails?['property'] as Map<String, dynamic>?,
  );

  late final TextEditingController _propertyNameController =
      TextEditingController(
    text: widget.propertyDetails?['name']?.toString() ?? '',
  );
  late final TextEditingController _slugController = TextEditingController(
    text: widget.propertyDetails?['slug_id']?.toString() ?? '',
  );
  late final TextEditingController _descriptionController =
      TextEditingController(
    text: widget.propertyDetails?['desc']?.toString() ?? '',
  );
  late final TextEditingController _cityNameController = TextEditingController(
    text: widget.propertyDetails?['city']?.toString() ?? '',
  );
  late final TextEditingController _stateNameController = TextEditingController(
    text: widget.propertyDetails?['state']?.toString() ?? '',
  );
  late final TextEditingController _countryNameController =
      TextEditingController(
    text: widget.propertyDetails?['country']?.toString() ?? '',
  );
  late final TextEditingController _latitudeController = TextEditingController(
    text: widget.propertyDetails?['latitude']?.toString() ?? '',
  );
  late final TextEditingController _longitudeController = TextEditingController(
    text: widget.propertyDetails?['longitude']?.toString() ?? '',
  );
  late final TextEditingController _addressController = TextEditingController(
    text: widget.propertyDetails?['address']?.toString() ?? '',
  );
  late final TextEditingController _priceController = TextEditingController(
    text: widget.propertyDetails?['price']?.toString() ?? '',
  );
  late final TextEditingController _clientAddressController =
      TextEditingController(
    text: widget.propertyDetails?['client']?.toString() ?? '',
  );

  late final TextEditingController _videoLinkController =
      TextEditingController();

  bool isPrivateProperty = false;

  ///META DETAILS
  late final TextEditingController metaTitleController =
      TextEditingController();
  late final TextEditingController metaDescriptionController =
      TextEditingController();
  late final TextEditingController metaKeywordController =
      TextEditingController();

  ///
  Map<dynamic, dynamic> propertyData = {};
  final PickImage _pickTitleImage = PickImage();
  final PickImage _propertiesImagePicker = PickImage();
  final PickImage _pick360deg = PickImage();
  // final PickImage _pickMetaTitle = PickImage();
  List<dynamic> editPropertyImageList = [];
  String threeDImageURL = '';
  String titleImageURL = '';
  // String metaImageUrl = '';
  String selectedRentType = 'Monthly';
  List<dynamic> removedImageId = [];
  int propertyType = 0;
  List<PropertyDocuments> documentFiles = [];
  List<int> removedDocumentId = [];
  int removeThreeDImage = 0;
  var localLatitude = 0.0;
  var localLongitude = 0.0;
  late final allPropData =
      widget.propertyDetails?['allPropData'] as Map<String, dynamic>? ?? {};

  // meta image new code
  late String metaImageUrl = allPropData['meta_image']?.toString() ?? '';
  late ImagePickerValue<dynamic>? metaImage =
      metaImageUrl != '' ? UrlValue(metaImageUrl) : null;

  List<dynamic> mixedPropertyImageList = [];

  PropertyModel? getEditPropertyData(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }
    return PropertyModel.fromMap(data);
  }

  @override
  void initState() {
    _propertyNameController.addListener(() {
      setState(() {
        if (property?.slugId != null && property?.slugId != '') {
          _slugController.text = property?.slugId ?? '';
        }
        _slugController.text = generateSlug(_propertyNameController.text);
      });
    });

    documentFiles =
        widget.properties?['documents'] as List<PropertyDocuments>? ?? [];
    propertyType = widget.propertyDetails?['propType'] == 'rent' ? 1 : 0;
    titleImageURL = widget.propertyDetails?['titleImage']?.toString() ?? '';
    threeDImageURL = widget.propertyDetails?['three_d_image']?.toString() ?? '';
    removeThreeDImage =
        widget.propertyDetails?['remove_three_d_image'] as int? ?? 0;
    metaImageUrl = allPropData['meta_image']?.toString() ?? '';

    mixedPropertyImageList = List<dynamic>.from(
      widget.propertyDetails?['images'] as Iterable<dynamic>? ?? [],
    );
    if (widget.propertyDetails != null) {
      selectedRentType =
          (widget.propertyDetails?['rentduration']).toString().isEmpty
              ? 'Monthly'
              : widget.propertyDetails?['rentduration']?.toString() ?? '';
      isPrivateProperty = allPropData['is_premium'] as bool? ?? false;
    }

    metaTitleController.text = allPropData['meta_title']?.toString() ?? '';
    metaDescriptionController.text =
        allPropData['meta_description']?.toString() ?? '';
    metaKeywordController.text = allPropData['meta_keywords']?.toString() ?? '';
    _propertiesImagePicker.listener((dynamic file) {
      if (_propertiesImagePicker.pickedFile != null) {
        try {
          mixedPropertyImageList.add(_propertiesImagePicker.pickedFile);
          setState(() {});
        } catch (e) {
          log('Error is $e');
        }
      }
    });

    _pickTitleImage.listener((dynamic file) {
      titleImageURL = '';
      if (mounted) setState(() {});
    });
    super.initState();
  }

  String generateSlug(String input) {
    return input
        .replaceAll(' ', '-')
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w-]'), '');
  }

  Future<void> _onTapChooseLocation(FormFieldState<dynamic> state) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (Hive.box<dynamic>(HiveKeys.userDetailsBox)
        .get('latitude')
        .toString()
        .isNotEmpty) {
      final dynamic latitudeValue =
          Hive.box<dynamic>(HiveKeys.userDetailsBox).get('latitude') ?? '0';
      localLatitude = double.tryParse(latitudeValue.toString()) ?? 0.0;
    }
    if (Hive.box<dynamic>(HiveKeys.userDetailsBox)
        .get('longitude')
        .toString()
        .isNotEmpty) {
      final dynamic longitudeValue =
          Hive.box<dynamic>(HiveKeys.userDetailsBox).get('longitude') ?? '0';
      localLongitude = double.tryParse(longitudeValue.toString()) ?? 0.0;
    }

    final placeMark = await Navigator.pushNamed(
      context,
      Routes.chooseLocaitonMap,
      arguments: {},
    ) as Map?;
    final latlng = placeMark?['latlng'] as LatLng?;
    final place = placeMark?['place'] as Placemark?;
    if (latlng != null && place != null) {
      _latitudeController.text = latlng.latitude.toString();
      _longitudeController.text = latlng.longitude.toString();
      _cityNameController.text = place.locality ?? '';
      _countryNameController.text = place.country ?? '';
      _stateNameController.text = place.administrativeArea ?? '';
      _addressController
        ..text = ''
        ..text = getAddress(place);

      state.didChange(true);
    } else {
      // state.didChange(false);
    }
  }

  String getAddress(Placemark place) {
    try {
      var address = '';
      if (place.street == null && place.subLocality != null) {
        address = place.subLocality!;
      } else if (place.street == null && place.subLocality == null) {
        address = '';
      } else {
        address = "${place.street ?? ""},${place.subLocality ?? ""}";
      }

      return address;
    } catch (e, st) {
      throw Exception('$st');
    }
  }

  Future<void> _onTapContinue() async {
    File? titleImage;
    File? v360Image;
    // File? metaTitle;

    if (_pickTitleImage.pickedFile != null) {
      titleImage = _pickTitleImage.pickedFile;
    }

    if (_pick360deg.pickedFile != null) {
      v360Image = _pick360deg.pickedFile;
    }

    if (_formKey.currentState!.validate()) {
      var documents = <String, dynamic>{};
      try {
        documents = documentFiles.fold({}, (pr, el) {
          pr.addAll({
            'documents[${pr.length}]': MultipartFile.fromFileSync(el.file!),
          });
          return pr;
        });
      } catch (e) {
        log('issue is $e');
      }

      _formKey.currentState?.save();
      final check = _checkIfLocationIsChosen();
      if (check == false) {
        Future.delayed(Duration.zero, () {
          UiUtils.showBlurredDialoge(
            context,
            sigmaX: 5,
            sigmaY: 5,
            dialog: BlurredDialogBox(
              svgImagePath: AppIcons.warning,
              title: UiUtils.translate(context, 'incomplete'),
              showCancleButton: false,
              onAccept: () async {},
              acceptTextColor: context.color.buttonColor,
              content: CustomText(
                UiUtils.translate(context, 'addressError'),
              ),
            ),
          );
        });

        return;
      } else if (titleImage == null && titleImageURL == '') {
        Future.delayed(Duration.zero, () {
          UiUtils.showBlurredDialoge(
            context,
            sigmaX: 5,
            sigmaY: 5,
            dialog: BlurredDialogBox(
              svgImagePath: AppIcons.warning,
              title: UiUtils.translate(context, 'incomplete'),
              showCancleButton: false,
              acceptTextColor: context.color.buttonColor,
              content: CustomText(
                UiUtils.translate(context, 'uploadImgMsgLbl'),
              ),
            ),
          );
        });
        return;
      } else if (titleImage?.path.split('.').last.toLowerCase() != 'jpg' &&
          titleImage?.path.split('.').last.toLowerCase() != 'png' &&
          titleImage?.path.split('.').last.toLowerCase() != 'jpeg' &&
          titleImageURL == '') {
        Future.delayed(Duration.zero, () {
          UiUtils.showBlurredDialoge(
            context,
            sigmaX: 5,
            sigmaY: 5,
            dialog: BlurredDialogBox(
              svgImagePath: AppIcons.warning,
              title: UiUtils.translate(context, 'incomplete'),
              showCancleButton: false,
              acceptTextColor: context.color.buttonColor,
              content: CustomText(
                UiUtils.translate(context, 'only jpg,jpeg and png supported'),
              ),
            ),
          );
        });
        return;
      }

      final list = mixedPropertyImageList.map((e) {
        if (e is File) {
          return e;
        }
      }).toList()
        ..removeWhere((element) => element == null);
      _clientAddressController
        ..clear()
        ..text = HiveUtils.getUserDetails().address ?? '';
      // metaImage?.value == metaImageUrl
      //     ? null
      //     :
      final metaImageData =
          metaImage?.value != '' && metaImage != null ? metaImage : null;

      propertyData.addAll({
        'title': _propertyNameController.text,
        'slug_id': _slugController.text,
        'description': _descriptionController.text,
        'city': _cityNameController.text,
        'state': _stateNameController.text,
        'country': _countryNameController.text,
        'latitude': _latitudeController.text,
        'longitude': _longitudeController.text,
        'address': _addressController.text,
        'client_address': _clientAddressController.text,
        'price': _priceController.text,
        'title_image': titleImage,
        'gallery_images': list,
        ...documents,
        'remove_gallery_images': removedImageId,
        'remove_documents': removedDocumentId,
        'remove_three_d_image': removeThreeDImage,
        'category_id': widget.propertyDetails == null
            ? (Constant.addProperty['category'] as Category).id
            : widget.propertyDetails?['catId'],
        'property_type': propertyType,
        'three_d_image': v360Image,
        'video_link': _videoLinkController.text,
        'meta_title': metaTitleController.text,
        'meta_description': metaDescriptionController.text,
        'meta_keywords': metaKeywordController.text,
        if (metaImageUrl != metaImage?.value) 'meta_image': metaImageData,
        if (propertyType == 1) 'rentduration': selectedRentType,
        'is_premium': isPrivateProperty,
      });

      if (widget.propertyDetails?.containsKey('assign_facilities') ?? false) {
        propertyData['assign_facilities'] =
            widget.propertyDetails!['assign_facilities'];
      }
      if (widget.propertyDetails != null) {
        propertyData['id'] = widget.propertyDetails?['id'];
        propertyData['action_type'] = '0';
      }

      Future.delayed(
        Duration.zero,
        () {
          _pickTitleImage.pauseSubscription();
          // _pickMetaTitle.pauseSubscription();
          Navigator.pushNamed(
            context,
            Routes.setPropertyParametersScreen,
            arguments: {
              'details': propertyData,
              'isUpdate': widget.propertyDetails != null,
            },
          ).then((value) {
            // _pickMetaTitle.resumeSubscription();
            _pickTitleImage.resumeSubscription();
          });
        },
      );
    }
  }

  bool _checkIfLocationIsChosen() {
    if (_cityNameController.text == '' ||
        _stateNameController.text == '' ||
        _countryNameController.text == '' ||
        _latitudeController.text == '' ||
        _longitudeController.text == '') {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    // _pickMetaTitle.dispose();
    _propertyNameController.dispose();
    _descriptionController.dispose();
    _cityNameController.dispose();
    _stateNameController.dispose();
    _countryNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _clientAddressController.dispose();
    _videoLinkController.dispose();
    _pick360deg.dispose();
    _pickTitleImage.dispose();
    _propertiesImagePicker.dispose();
    _slugController.dispose();
    super.dispose();
  }

  List<Widget> documentsList() {
    return documentFiles.map((documents) {
      return ListTile(
        title: CustomText(
          documents.name,
          maxLines: 2,
        ),
        dense: true,
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (documents.id != null) {
              removedDocumentId.add(documents.id!);
            }
            documentFiles.remove(documents);
            setState(() {});
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const requiredSymbol = CustomText(
      '*',
      color: Colors.redAccent,
    );
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      bottomNavigationBar: ColoredBox(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: UiUtils.buildButton(
            context,
            onPressed: _onTapContinue,
            height: 48.rh(context),
            fontSize: context.font.large,
            buttonTitle: UiUtils.translate(context, 'next'),
          ),
        ),
      ),
      appBar: UiUtils.buildAppBar(
        context,
        title: widget.propertyDetails == null
            ? UiUtils.translate(context, 'ddPropertyLbl')
            : UiUtils.translate(context, 'updateProperty'),
        actions: const [
          Spacer(),
          CustomText('2/4'),
          SizedBox(
            width: 14,
          ),
        ],
        showBackButton: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: Constant.scrollPhysics,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomText('propertyType'.translate(context)),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  buildPropertyTypeSelector(context),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  Row(
                    children: [
                      CustomText(UiUtils.translate(context, 'propertyNameLbl')),
                      const SizedBox(width: 3),
                      requiredSymbol,
                    ],
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomTextFormField(
                    controller: _propertyNameController,
                    validator: CustomTextFieldValidator.nullCheck,
                    action: TextInputAction.next,
                    hintText: UiUtils.translate(context, 'propertyNameLbl'),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomText(UiUtils.translate(context, 'slugIdLbl')),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomTextFormField(
                    controller: _slugController,
                    validator: CustomTextFieldValidator.slugId,
                    action: TextInputAction.next,
                    hintText: UiUtils.translate(context, 'slugIdOptional'),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  Row(
                    children: [
                      CustomText(UiUtils.translate(context, 'descriptionLbl')),
                      const SizedBox(width: 3),
                      requiredSymbol,
                    ],
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomTextFormField(
                    action: TextInputAction.next,
                    controller: _descriptionController,
                    validator: CustomTextFieldValidator.nullCheck,
                    hintText: UiUtils.translate(context, 'writeSomething'),
                    maxLine: 100,
                    minLine: 6,
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          'isPrivateProperty'.translate(context),
                        ),
                      ),
                      CupertinoSwitch(
                        value: isPrivateProperty,
                        activeTrackColor: context.color.tertiaryColor,
                        onChanged: (bool value) {
                          isPrivateProperty = value;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  SizedBox(
                    height: 35.rh(context),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CustomText(
                                UiUtils.translate(context, 'addressLbl'),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              requiredSymbol,
                            ],
                          ),
                        ),
                        // const Spacer(),
                        ChooseLocationFormField(
                          initialValue: false,
                          validator: (bool? value) {
                            //Check if it has already data so we will not validate it.
                            if (widget.propertyDetails != null) {
                              return null;
                            }

                            if (value ?? false) {
                              return null;
                            } else {
                              return 'Select location';
                            }
                          },
                          build: (state) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.5,
                                  color: state.hasError
                                      ? Colors.red
                                      : Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: InkWell(
                                onTap: () {
                                  _onTapChooseLocation.call(state);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    UiUtils.getSvg(
                                      AppIcons.location,
                                      color: context.color.textLightColor,
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    CustomText(
                                      UiUtils.translate(
                                        context,
                                        'chooseLocation',
                                      ),
                                      fontSize: context.font.normal,
                                      color: context.color.tertiaryColor,
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    requiredSymbol,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomTextFormField(
                    action: TextInputAction.next,
                    controller: _cityNameController,
                    isReadOnly: false,
                    validator: CustomTextFieldValidator.nullCheck,
                    hintText: UiUtils.translate(context, 'city'),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomTextFormField(
                    action: TextInputAction.next,
                    controller: _stateNameController,
                    isReadOnly: false,
                    validator: CustomTextFieldValidator.nullCheck,
                    hintText: UiUtils.translate(context, 'state'),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomTextFormField(
                    action: TextInputAction.next,
                    controller: _countryNameController,
                    isReadOnly: false,
                    validator: CustomTextFieldValidator.nullCheck,
                    hintText: UiUtils.translate(context, 'country'),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomTextFormField(
                    action: TextInputAction.next,
                    controller: _addressController,
                    hintText: UiUtils.translate(context, 'addressLbl'),
                    maxLine: 100,
                    validator: CustomTextFieldValidator.nullCheck,
                    minLine: 4,
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomTextFormField(
                    action: TextInputAction.next,
                    controller: _clientAddressController,
                    validator: CustomTextFieldValidator.nullCheck,
                    hintText: UiUtils.translate(context, 'clientaddressLbl'),
                    maxLine: 100,
                    minLine: 4,
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  if (propertyType == 1) ...[
                    Row(
                      children: [
                        CustomText(UiUtils.translate(context, 'rentPrice')),
                        const SizedBox(
                          width: 3,
                        ),
                        requiredSymbol,
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        CustomText(UiUtils.translate(context, 'price')),
                        const SizedBox(
                          width: 3,
                        ),
                        requiredSymbol,
                      ],
                    ),
                  ],
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          action: TextInputAction.next,
                          prefix: Padding(
                            padding: const EdgeInsets.all(20),
                            child: CustomText(
                              '${Constant.currencySymbol} ',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          controller: _priceController,
                          formaters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*'),
                            ),
                          ],
                          isReadOnly: false,
                          keyboard: TextInputType.number,
                          validator: CustomTextFieldValidator.nullCheck,
                          hintText: '00',
                        ),
                      ),
                      if (propertyType == 1) ...[
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor,
                            border: Border.all(
                              color: context.color.borderColor,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: DropdownButton<String>(
                              value: selectedRentType,
                              dropdownColor: context.color.primaryColor,
                              underline: const SizedBox.shrink(),
                              items: [
                                DropdownMenuItem(
                                  value: 'Daily',
                                  child: CustomText(
                                    'Daily'.translate(context),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Monthly',
                                  child:
                                      CustomText('Monthly'.translate(context)),
                                ),
                                DropdownMenuItem(
                                  value: 'Quarterly',
                                  child: CustomText(
                                    'Quarterly'.translate(context),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Yearly',
                                  child:
                                      CustomText('Yearly'.translate(context)),
                                ),
                              ],
                              onChanged: (value) {
                                selectedRentType = value ?? '';
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  Row(
                    children: [
                      CustomText(UiUtils.translate(context, 'uploadPictures')),
                      const SizedBox(
                        width: 3,
                      ),
                      CustomText(
                        'maxSize'.translate(context),
                        fontStyle: FontStyle.italic,
                        fontSize: context.font.small,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  Wrap(
                    children: [
                      if (_pickTitleImage.pickedFile != null) ...[] else ...[],
                      titleImageListener(),
                    ],
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomText(UiUtils.translate(context, 'otherPictures')),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  propertyImagesListener(),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  DottedBorder(
                    color: context.color.textLightColor,
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: GestureDetector(
                      onTap: () {
                        _pick360deg.pick(pickMultiple: false);
                      },
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        height: 48.rh(context),
                        child: CustomText(
                          UiUtils.translate(context, 'add360degPicture'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  // SHOW 360 PICTURE CODE
                  _pick360deg.listenChangesInUI((context, image) {
                    if (image != null) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(5),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.file(
                              image as File,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute<dynamic>(
                                    builder: (context) {
                                      return PanaromaImageScreen(
                                        imageUrl: image.path,
                                        isFileImage: true,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.all(5),
                                height: 100,
                                decoration: BoxDecoration(
                                  color: context.color.tertiaryColor.withValues(
                                    alpha: 0.68,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.none,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: context.color.secondaryColor,
                                    ),
                                    width: 60.rw(context),
                                    height: 60.rh(context),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 30.rh(context),
                                            width: 40.rw(context),
                                            child: UiUtils.getSvg(
                                              AppIcons.v360Degree,
                                              color:
                                                  context.color.textColorDark,
                                            ),
                                          ),
                                          CustomText(
                                            UiUtils.translate(context, 'view'),
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.font.small,
                                            color: context.color.textColorDark,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          closeButton(context, () {
                            threeDImageURL.isNotEmpty
                                ? removeThreeDImage = 1
                                : removeThreeDImage = 0;
                            if (removeThreeDImage == 1) {
                              _pick360deg.listenChangesInUI((context, image) {
                                if (image != null || threeDImageURL != '') {
                                  threeDImageURL = '';
                                  image = null;
                                  setState(() {});
                                  return const SizedBox.shrink();
                                }
                              });
                            }
                            setState(() {});
                            return const SizedBox.shrink();
                          }),
                        ],
                      );
                    }
                    return Container();
                  }),
                  _pick360deg.listenChangesInUI((context, image) {
                    if (threeDImageURL != '' && image == null) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(5),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.network(
                              threeDImageURL,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute<dynamic>(
                                    builder: (context) {
                                      return PanaromaImageScreen(
                                        imageUrl: threeDImageURL,
                                        isFileImage: true,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.all(5),
                                height: 100,
                                decoration: BoxDecoration(
                                  color: context.color.tertiaryColor.withValues(
                                    alpha: 0.68,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.none,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: context.color.secondaryColor,
                                    ),
                                    width: 60.rw(context),
                                    height: 60.rh(context),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 30.rh(context),
                                            width: 40.rw(context),
                                            child: UiUtils.getSvg(
                                              AppIcons.v360Degree,
                                              color:
                                                  context.color.textColorDark,
                                            ),
                                          ),
                                          CustomText(
                                            UiUtils.translate(context, 'view'),
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.font.small,
                                            color: context.color.textColorDark,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          closeButton(context, () {
                            setState(() {
                              _pick360deg.clearImage();
                              threeDImageURL = '';
                              removeThreeDImage = 1;
                            });
                          }),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomText(UiUtils.translate(context, 'additionals')),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomTextFormField(
                    // prefix: CustomText("${Constant.currencySymbol} "),
                    controller: _videoLinkController,
                    // isReadOnly: widget.properyDetails != null,
                    hintText: 'http://example.com/video.mp4',
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomText('propertyDocuments'.translate(context)),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  buildDocumentsPicker(context),
                  ...documentsList(),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomText('Meta Details'.translate(context)),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomTextFormField(
                    controller: metaTitleController,
                    hintText: 'Title'.translate(context),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: CustomText(
                      'metaTitleLength'.translate(context),
                      fontSize: context.font.small - 1.5,
                      color: context.color.textLightColor,
                    ),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomTextFormField(
                    controller: metaDescriptionController,
                    hintText: 'Description'.translate(context),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: CustomText(
                      'metaDescriptionLength'.translate(context),
                      fontSize: context.font.small - 1.5,
                      color: context.color.textLightColor,
                    ),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomTextFormField(
                    controller: metaKeywordController,
                    hintText: 'Keywords'.translate(context),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: CustomText(
                      'metaKeywordsLength'.translate(context),
                      fontSize: context.font.small - 1.5,
                      color: context.color.textLightColor,
                    ),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  AdaptiveImagePickerWidget(
                    isRequired: false,
                    title: UiUtils.translate(context, 'addMetaImage'),
                    multiImage: false,
                    value: metaImage,
                    onSelect: (ImagePickerValue<dynamic>? selected) {
                      if (selected is FileValue || selected == null) {
                        metaImage = selected;
                        setState(() {});
                      }
                    },
                    onRemove: (value) {
                      if (value is UrlValue) {
                        metaImage = UrlValue('');
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecorator buildPropertyTypeSelector(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        hintStyle: TextStyle(
          color: context.color.textColorDark.withValues(alpha: 0.7),
          fontSize: context.font.large,
        ),
        filled: true,
        fillColor: context.color.secondaryColor,
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 1.5, color: context.color.tertiaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: context.color.borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: context.color.borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: DropdownButton<int>(
        value: propertyType,
        isExpanded: true,
        isDense: true,
        borderRadius: BorderRadius.zero,
        padding: EdgeInsets.zero,
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem(
            value: 0,
            child: CustomText('sell'.translate(context)),
          ),
          DropdownMenuItem(
            value: 1,
            child: CustomText('rent'.translate(context)),
          ),
        ],
        onTap: () {},
        onChanged: (int? value) {
          propertyType = value!;
          setState(() {});
        },
      ),
    );
  }

  Widget propertyImagesListener() {
    return _propertiesImagePicker.listenChangesInUI((context, file) {
      Widget current = Container();

      current = Wrap(
        children: mixedPropertyImageList
            .map((image) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      HelperUtils.unfocus();
                      if (image is String) {
                        UiUtils.showFullScreenImage(
                          context,
                          provider: NetworkImage(image),
                        );
                      } else {
                        UiUtils.showFullScreenImage(
                          context,
                          provider: FileImage(image as File),
                        );
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.all(5),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ImageAdapter(
                        image: image,
                      ),
                    ),
                  ),
                  closeButton(context, () {
                    mixedPropertyImageList.remove(image);

                    if (image is String) {
                      final properyDetail = widget
                          .propertyDetails?['gallary_with_id'] as List<Gallery>;
                      final id = properyDetail
                          .where((element) => element.imageUrl == image)
                          .first
                          .id;

                      removedImageId.add(id);
                    }
                    setState(() {});
                  }),
                ],
              );
            })
            .toList()
            .cast<Widget>(),
      );

      return Wrap(
        children: [
          if (file == null && mixedPropertyImageList.isEmpty)
            DottedBorder(
              color: context.color.textLightColor,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: GestureDetector(
                onTap: () {
                  _propertiesImagePicker.pick(pickMultiple: true);
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  height: 48.rh(context),
                  child:
                      CustomText(UiUtils.translate(context, 'addOtherPicture')),
                ),
              ),
            ),
          current,
          if (file != null || titleImageURL != '')
            uploadPhotoCard(
              context,
              onTap: () {
                _propertiesImagePicker.pick(pickMultiple: true);
              },
            ),
        ],
      );
    });
  }

  Widget titleImageListener() {
    return Builder(
      builder: (context) {
        Widget currentWidget = Container();
        if (titleImageURL != '') {
          currentWidget = GestureDetector(
            onTap: () {
              UiUtils.showFullScreenImage(
                context,
                provider: NetworkImage(titleImageURL),
              );
            },
            child: Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(5),
              clipBehavior: Clip.antiAlias,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Image.network(
                titleImageURL,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        if (_pickTitleImage.pickedFile is File) {
          currentWidget = GestureDetector(
            onTap: () {
              UiUtils.showFullScreenImage(
                context,
                provider: FileImage(_pickTitleImage.pickedFile!),
              );
            },
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.all(5),
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.file(
                    _pickTitleImage.pickedFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          );
        }

        return Wrap(
          children: [
            if (_pickTitleImage.pickedFile == null && titleImageURL == '')
              DottedBorder(
                color: context.color.textLightColor,
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: GestureDetector(
                  onTap: () {
                    _pickTitleImage.pick(pickMultiple: false);
                    titleImageURL = '';
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    height: 48.rh(context),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: UiUtils.translate(context, 'addMainPicture'),
                          ),
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Stack(
              children: [
                currentWidget,
                closeButton(context, () {
                  _pickTitleImage.clearImage();
                  titleImageURL = '';
                  setState(() {});
                }),
              ],
            ),
            if (_pickTitleImage.pickedFile != null || titleImageURL != '')
              uploadPhotoCard(
                context,
                onTap: () {
                  _pickTitleImage
                    ..resumeSubscription()
                    ..pick(pickMultiple: false)
                    ..pauseSubscription();
                  titleImageURL = '';
                  setState(() {});
                },
              ),
          ],
        );
      },
    );
  }

  Widget buildDocumentsPicker(BuildContext context) {
    return Row(
      children: [
        DottedBorder(
          borderType: BorderType.RRect,
          color: context.color.textLightColor,
          radius: const Radius.circular(20),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Center(
              child: IconButton(
                onPressed: () async {
                  final filePickerResult = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                  );
                  if (filePickerResult != null) {
                    final list =
                        filePickerResult.files.map<PropertyDocuments>((e) {
                      return PropertyDocuments(
                        name: e.name,
                        file: e.path,
                      );
                    });
                    documentFiles.addAll(list);
                  }

                  setState(() {});
                },
                icon: const Icon(Icons.upload),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText('UploadDocs'.translate(context)),
            const SizedBox(
              height: 4,
            ),
            CustomText(documentFiles.length.toString()),
          ],
        ),
      ],
    );
  }
}

Widget uploadPhotoCard(BuildContext context, {required Function onTap}) {
  return GestureDetector(
    onTap: () {
      onTap.call();
    },
    child: Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.all(5),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: DottedBorder(
        color: context.color.textColorDark.withValues(alpha: 0.5),
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        child: Container(
          alignment: Alignment.center,
          child: CustomText('uploadPhoto'.translate(context)),
        ),
      ),
    ),
  );
}

PositionedDirectional closeButton(BuildContext context, Function onTap) {
  return PositionedDirectional(
    top: 6,
    end: 6,
    child: GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.color.primaryColor.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(
            Icons.close,
            size: 24,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
}

class ChooseLocationFormField extends FormField<bool> {
  ChooseLocationFormField({
    required Widget Function(FormFieldState<bool> state) build,
    super.key,
    super.onSaved,
    super.validator,
    super.initialValue,
  }) : super(
          builder: (FormFieldState<bool> state) {
            return build(state);
          },
        );
}

class ImageAdapter extends StatelessWidget {
  const ImageAdapter({super.key, this.image});

  final dynamic image;

  @override
  Widget build(BuildContext context) {
    if (image is String) {
      return Image.network(
        image?.toString() ?? '',
        fit: BoxFit.cover,
      );
    } else if (image is File) {
      return Image.file(
        image as File,
        fit: BoxFit.cover,
      );
    }
    return Container();
  }
}
