import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/color.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/sliver_component.dart';
import 'package:askaide/page/draw/components/creative_item.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class DrawScreen extends StatefulWidget {
  final SettingRepository setting;
  const DrawScreen({super.key, required this.setting});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  @override
  void initState() {
    if (Ability().supportAPIServer()) {
      userSignedIn = true;
    }

    context
        .read<CreativeIslandBloc>()
        .add(CreativeIslandItemsV2LoadEvent(forceRefresh: false));

    super.initState();
  }

  bool userSignedIn = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return BackgroundContainer(
      setting: widget.setting,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildIslandItems(customColors),
      ),
    );
  }

  /// 创作岛列表
  Widget _buildIslandItems(
    CustomColors customColors,
  ) {
    return SliverComponent(
      title: Text(
        AppLocale.creativeIsland.getString(context),
        style: TextStyle(
          fontSize: CustomSize.appBarTitleSize,
          color: customColors.backgroundInvertedColor,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            if (userSignedIn) {
              context.push('/creative-island/history?mode=image-draw');
            } else {
              context.push('/login');
            }
          },
          icon: const Icon(Icons.crop_original),
        ),
      ],
      backgroundImage: Image.asset(
        customColors.appBarBackgroundImageForCreativeIsland!,
        fit: BoxFit.cover,
      ),
      child: BlocBuilder<CreativeIslandBloc, CreativeIslandState>(
        buildWhen: (previous, current) =>
            current is CreativeIslandItemsV2Loaded,
        builder: (context, state) {
          if (state is CreativeIslandItemsV2Loaded) {
            return GridView.count(
              crossAxisCount: _calCrossAxisCount(context),
              childAspectRatio: 2,
              children: state.items
                  .map((e) => CreativeItem(
                        imageURL: e.previewImage,
                        title: e.title,
                        titleColor: stringToColor(e.titleColor),
                        tag: e.tag,
                        onTap: () {
                          if (userSignedIn) {
                            context.push(e.routeUri);
                          } else {
                            context.push('/login');
                          }
                        },
                      ))
                  .toList(),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  int _calCrossAxisCount(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (width > CustomSize.maxWindowSize) {
      width = CustomSize.maxWindowSize;
    }

    return (width / 400).round();
  }
}
