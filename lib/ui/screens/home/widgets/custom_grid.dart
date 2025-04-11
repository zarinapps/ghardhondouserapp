import 'package:ebroker/data/cubits/property/fetch_city_property_list.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/city_properties_screen.dart';
import 'package:flutter/material.dart';

class CustomImageGrid extends StatelessWidget {
  const CustomImageGrid({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * 0.9;
        final itemWidth = width / 2;
        final standardHeight = itemWidth;
        final doubleHeight = (standardHeight * 2) + 5;
        final state = context.read<FetchCityCategoryCubit>().state
            as FetchCityCategorySuccess;

        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      _buildImageContainer(
                          index: 0,
                          width: itemWidth,
                          height: standardHeight,
                          state: state,
                          context: context),
                      _buildImageContainer(
                          index: 1,
                          width: itemWidth,
                          height: standardHeight,
                          state: state,
                          context: context),
                    ],
                  ),
                  _buildImageContainer(
                      index: 2,
                      width: itemWidth,
                      height: doubleHeight,
                      state: state,
                      context: context),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildImageContainer(
                          index: 3,
                          width: itemWidth,
                          height: standardHeight,
                          state: state,
                          context: context),
                      _buildImageContainer(
                          index: 4,
                          width: itemWidth,
                          height: doubleHeight,
                          state: state,
                          context: context),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildImageContainer(
                          index: 5,
                          width: itemWidth,
                          height: doubleHeight,
                          state: state,
                          context: context),
                      _buildImageContainer(
                          index: 6,
                          width: itemWidth,
                          height: standardHeight,
                          state: state,
                          context: context),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  _buildImageContainer(
                      index: 7,
                      width: itemWidth,
                      height: doubleHeight,
                      state: state,
                      context: context),
                  Column(
                    children: [
                      _buildImageContainer(
                          index: 8,
                          width: itemWidth,
                          height: standardHeight,
                          state: state,
                          context: context),
                      _buildImageContainer(
                          index: 9,
                          width: itemWidth,
                          height: standardHeight,
                          state: state,
                          context: context),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageContainer(
      {required int index,
      required double width,
      required double height,
      required FetchCityCategorySuccess state,
      required BuildContext context}) {
    if (index >= state.cities.length) {
      return SizedBox(
          width: width,
          height: height); // Fixed: Return sized box with dimensions
    }
    final city = state.cities[index];
    return Container(
      width: width, // Fixed: Added explicit width
      height: height, // Fixed: Added explicit height
      margin:
          const EdgeInsets.all(2), // Optional: Add small margin between cells
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: GestureDetector(
          onTap: () {
            context.read<FetchCityPropertyList>().fetch(
                  cityName: city.name,
                  forceRefresh: true,
                );
            Navigator.push(
              context,
              BlurredRouter(
                builder: (context) {
                  return CityPropertiesScreen(
                    cityName: city.name,
                  );
                },
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              UiUtils.getImage(
                city.image,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.68),
                      Colors.black.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: 8,
                start: 12,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      city.name.firstUpperCase(),
                      color: context.color.buttonColor,
                      fontSize: context.font.normal,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    CustomText(
                      '${city.count} ${'properties'.translate(context)}',
                      color: context.color.buttonColor,
                      fontSize: context.font.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
