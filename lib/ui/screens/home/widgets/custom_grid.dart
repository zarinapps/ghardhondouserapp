import 'package:ebroker/data/cubits/property/fetch_city_property_list.dart';
import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/city_properties_screen.dart';
import 'package:flutter/material.dart';

class CustomImageGrid extends StatelessWidget {
  const CustomImageGrid({
    required this.cities,
    super.key,
  });

  final List<City> cities;

  @override
  Widget build(BuildContext context) {
    // Get the actual number of cities
    final cityCount = cities.length;

    // If no cities, return empty container
    if (cityCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                _buildImageContainer(
                  index: 0,
                  isBig: false,
                  context: context,
                ),
                if (cityCount > 1)
                  _buildImageContainer(
                    index: 1,
                    isBig: false,
                    context: context,
                  ),
              ],
            ),
            if (cityCount > 2)
              _buildImageContainer(
                index: 2,
                isBig: true,
                context: context,
              ),
          ],
        ),

        // Only show additional rows if we have more cities
        if (cityCount > 3) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildImageContainer(
                    index: 3,
                    isBig: false,
                    context: context,
                  ),
                  if (cityCount > 5)
                    _buildImageContainer(
                      index: 5,
                      isBig: true,
                      context: context,
                    ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cityCount > 4)
                    _buildImageContainer(
                      index: 4,
                      isBig: true,
                      context: context,
                    ),
                  if (cityCount > 6)
                    _buildImageContainer(
                      index: 6,
                      isBig: false,
                      context: context,
                    ),
                ],
              ),
            ],
          ),
        ],

        // Only show the last row if we have more than 7 cities
        if (cityCount > 7) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageContainer(
                index: 7,
                isBig: true,
                context: context,
              ),
              Column(
                children: [
                  if (cityCount > 8)
                    _buildImageContainer(
                      index: 8,
                      isBig: false,
                      context: context,
                    ),
                  if (cityCount > 9)
                    _buildImageContainer(
                      index: 9,
                      isBig: false,
                      context: context,
                    ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImageContainer({
    required int index,
    required bool isBig,
    required BuildContext context,
  }) {
    final itemWidth = (MediaQuery.of(context).size.width / 2) * 0.9;
    final standardHeight = itemWidth;
    final doubleHeight = (standardHeight * 2) + 4;

    if (index >= cities.length) {
      return SizedBox(
        width: itemWidth,
        height: isBig ? doubleHeight : standardHeight,
      );
    }
    final city = cities[index];
    return Container(
      margin: const EdgeInsets.all(2),
      width: itemWidth,
      height: isBig ? doubleHeight : standardHeight,
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
              CupertinoPageRoute<dynamic>(
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
