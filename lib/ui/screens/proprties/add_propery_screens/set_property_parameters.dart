// ignore_for_file: depend_on_referenced_packages

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/proprties/Property%20tab/sell_rent_screen.dart';
import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/ui/screens/proprties/add_propery_screens/property_success.dart';
import 'package:ebroker/ui/screens/widgets/animated_routes/scale_up_route.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart' as h;
import 'package:mime/mime.dart';

class SetProeprtyParametersScreen extends StatefulWidget {
  const SetProeprtyParametersScreen({
    required this.propertyDetails,
    required this.isUpdate,
    super.key,
  });
  final Map<dynamic, dynamic> propertyDetails;
  final bool isUpdate;
  static Route<dynamic> route(RouteSettings settings) {
    final argument = settings.arguments as Map<dynamic, dynamic>?;

    return CupertinoPageRoute(
      builder: (context) {
        return SetProeprtyParametersScreen(
          propertyDetails: argument?['details'] as Map<dynamic, dynamic>? ?? {},
          isUpdate: argument?['isUpdate'] as bool,
        );
      },
    );
  }

  @override
  State<SetProeprtyParametersScreen> createState() =>
      _SetProeprtyParametersScreenState();
}

class _SetProeprtyParametersScreenState
    extends State<SetProeprtyParametersScreen>
    with AutomaticKeepAliveClientMixin {
  List<ValueNotifier<dynamic>> disposableFields = [];
  bool newCustomFields = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  List<dynamic> galleryImage = [];
  File? titleImage;
  File? t360degImage;
  ImagePickerValue<dynamic>? metaImage;
  Map<String, dynamic>? apiParameters;
  List<RenderCustomFields> paramaeterUI = [];
  bool paramIsRequired = false;
  @override
  void initState() {
    apiParameters = Map.from(widget.propertyDetails);
    galleryImage = apiParameters!['gallery_images'] as List;
    titleImage = apiParameters!['title_image'] as File?;
    t360degImage = apiParameters!['three_d_image'] as File?;
    metaImage = apiParameters!['meta_image'] as ImagePickerValue?;
    Future.delayed(
      Duration.zero,
      () {
        paramaeterUI =
            (Constant.addProperty['category']?.parameterTypes as List)
                .mapIndexed((index, element) {
          var data = element;

          if (element is! Map) {
            data = (element as Parameter).toMap();
          }
          return RenderCustomFields(
            isRequired: data['is_required'] == 1,
            index: index,
            field:
                KRegisteredFields().get(data['type_of_parameter'].toString()) ??
                    BlankField(),
            data: data as Map<String, dynamic>,
          );
        }).toList();

        setState(() {});
      },
    );
    super.initState();
  }

  ///This will convert {0:Demo} to it's required format here we have assigned Parameter id : value, before.

  List<RenderCustomFields> buildFields() {
    if (Constant.addProperty['category'] == null) {
      return [
        RenderCustomFields(
          isRequired: false,
          field: BlankField(),
          data: const {},
          index: 0,
        ),
      ];
    }

    ///Loop parameters
    return paramaeterUI;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        actions: const [
          Spacer(),
          CustomText('3/4'),
          SizedBox(
            width: 14,
          ),
        ],
        title: widget.isUpdate
            ? UiUtils.translate(context, 'updateProperty')
            : UiUtils.translate(context, 'ddPropertyLbl'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: UiUtils.buildButton(
          context,
          height: 48.rh(context),
          onPressed: () async {
            final parameterValues = paramaeterUI.fold<Map<String, dynamic>>({},
                (previousValue, element) {
              final value = element.getValue();
              if (value != null && value.toString().isNotEmpty) {
                previousValue.addAll({
                  'parameters[${previousValue.length ~/ 2}][parameter_id]':
                      element.getId(),
                  'parameters[${previousValue.length ~/ 2}][value]': value,
                });
              }
              return previousValue;
            });
            apiParameters?.addAll(Map.from(parameterValues));

            // Check if all required parameters are filled
            var allRequiredParamsFilled = true;

            for (final element in paramaeterUI) {
              if (element.isRequired) {
                if (element.data['image'] == '' ||
                    element.data['image'] == null ||
                    element.getValue() == null ||
                    element.getValue().toString().trim().isEmpty ||
                    element.getValue() == '') {
                  allRequiredParamsFilled = false;
                } else {
                  allRequiredParamsFilled = true;
                }
              }
            }

            if (allRequiredParamsFilled != true) {
              final inputs = ['*'];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text.rich(
                    TextSpan(
                      children: UiUtils.translate(
                        context,
                        'pleaseFillRequiredFields',
                      )
                          .characters
                          .map(
                            (e) => inputs.contains(e)
                                ? TextSpan(
                                    text: e,
                                    style: TextStyle(
                                      color: context.color.errorContainer,
                                    ),
                                  )
                                : TextSpan(
                                    text: e,
                                    style: TextStyle(
                                      color: context.color.primaryColor,
                                    ),
                                  ),
                          )
                          .toList(),
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: successMessageColor,
                  duration: const Duration(seconds: 3),
                ),
              );
              return; // Exit the function early if required params are not filled
            }
            // UiUtils.translate(context, 'pleaseFillRequiredFields')
            final gallery = <MultipartFile>[];
            await Future.forEach(
              galleryImage,
              (item) async {
                final multipartFile =
                    await MultipartFile.fromFile((item?.path ?? '').toString());
                if (!multipartFile.isFinalized) {
                  gallery.add(multipartFile);
                }
              },
            );
            apiParameters!['gallery_images'] = gallery;

            if (titleImage != null) {
              final mimeType = lookupMimeType((titleImage!).path);
              final extension = mimeType!.split('/');
              apiParameters!['title_image'] = await MultipartFile.fromFile(
                (titleImage!).path,
                contentType: h.MediaType('image', extension[1]),
                filename: (titleImage!).path.split('/').last,
              );
            }

            if (t360degImage != null) {
              final mimeType = lookupMimeType(t360degImage!.path);
              final extension = mimeType!.split('/');
              apiParameters!['three_d_image'] = await MultipartFile.fromFile(
                t360degImage?.path ?? '',
                contentType: h.MediaType('image', extension[1]),
                filename: t360degImage?.path.split('/').last,
              );
            }

            if (metaImage != null) {
              final mimeType =
                  lookupMimeType(metaImage!.value.path?.toString() ?? '');
              final extension = mimeType!.split('/');
              apiParameters!['meta_image'] = await MultipartFile.fromFile(
                metaImage?.value.path?.toString() ?? '',
                contentType: h.MediaType('image', extension[1]),
                filename: metaImage?.value.path.split('/').last?.toString(),
              );
            }
            // if (meta_image == null) {
            //   apiParameters!['meta_image'] = '';
            // }

            // If we've reached this point, all required params are filled and images are processed
            apiParameters?['isUpdate'] = widget.isUpdate;
            await Navigator.pushNamed(
              context,
              Routes.selectOutdoorFacility,
              arguments: apiParameters,
            );
          },
          buttonTitle: UiUtils.translate(context, 'next'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: BlocListener<CreatePropertyCubit, CreatePropertyState>(
          listener: (context, state) {
            if (state is CreatePropertyInProgress) {
              Widgets.showLoader(context);
            }

            if (state is CreatePropertyFailure) {
              Widgets.hideLoder(context);
              HelperUtils.showSnackBarMessage(context, state.errorMessage);
            }
            if (state is CreatePropertySuccess) {
              Widgets.hideLoder(context);
              if (widget.isUpdate == false) {
                ref[propertyType ?? 'sell']
                    ?.fetchMyProperties(type: propertyType ?? 'sell');
                Future.delayed(
                  Duration.zero,
                  () {
                    Navigator.pushReplacement(
                      context,
                      ScaleUpRouter<dynamic>(
                        builder: (context) {
                          return PropertyAddSuccess(
                            model: state.propertyModel!,
                          );
                        },
                        current: widget,
                      ),
                    );
                  },
                );
              } else {
                context.read<PropertyEditCubit>().add(state.propertyModel!);
                context
                    .read<FetchMyPropertiesCubit>()
                    .update(state.propertyModel!);
                cubitReference?.update(state.propertyModel!);
                HelperUtils.showSnackBarMessage(
                  context,
                  UiUtils.translate(context, 'propertyUpdated'),
                  messageDuration: 1,
                  type: MessageType.success,
                  onClose: () {
                    Widgets.hideLoder(context);
                    Future.delayed(
                      Duration.zero,
                      () {
                        Navigator.push(
                          context,
                          ScaleUpRouter<dynamic>(
                            builder: (context) {
                              return PropertyAddSuccess(
                                model: state.propertyModel!,
                              );
                            },
                            current: widget,
                          ),
                        );
                      },
                    );
                  },
                );
              }
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              physics: Constant.scrollPhysics,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(UiUtils.translate(context, 'addvalues')),
                    const SizedBox(
                      height: 18,
                    ),
                    ...buildFields(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
