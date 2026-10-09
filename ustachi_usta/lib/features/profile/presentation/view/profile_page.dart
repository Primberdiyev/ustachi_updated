import 'package:flutter/cupertino.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as m show Text;
import 'package:ustachi/application/language_provider.dart';
import 'package:ustachi/features/auth/presentation/view/country_select_page.dart';
import 'package:ustachi/features/profile/presentation/view/company/company_page.dart';
import 'package:ustachi/features/profile/presentation/view/master_professional_page.dart';
import 'package:ustachi/features/profile/presentation/view/master_materials_page.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/router_impls/auth/auth_router_impl.dart';
import 'package:ustachi/core/services/session_cleanup_service.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/utils/uikit/show_error_widget.dart';
import 'package:ustachi/core/utils/uikit/show_loader_widget.dart';
import 'package:ustachi/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ustachi/features/profile/domain/models/profile_item_model.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';
import 'package:ustachi/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ustachi/features/profile/presentation/widgets/logout_button.dart';
import 'package:ustachi/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:ustachi/features/profile/presentation/widgets/logout_progress_dialog.dart';
import 'package:ustachi/features/profile/presentation/widgets/profile_menu_item_widget.dart';
import 'package:ustachi/features/profile/presentation/widgets/user_avatar_widget.dart';
import 'package:ustachi/features/profile/presentation/view/personal_data_page.dart';
import 'package:ustachi/features/profile/presentation/widgets/support_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool _hasRom = false;

  Future<void> _loadHasRom() async {
    final profile = await MasterProfileApi(sl<Dio>()).read();
    if (!mounted) return;
    setState(() => _hasRom = profile?.hasRom ?? false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await LogoutConfirmDialog.show(context);
    if (!confirmed || !mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    LogoutProgressDialog.show(context);

    final result = await sl<LogoutUseCase>()(NoParams());
    await sl<SessionCleanupService>().clearSessionData();
    if (navigator.canPop()) navigator.pop();
    if (!mounted) return;

    if (result.isLeft) {
      sl<SnackbarService>().showMessage(context.t.profile.logoutFailed);
    }
    AuthRouterImpl().replaceWithPhoneAuth(context);
  }

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ProfileBloc>();
    if (bloc.state.getUserDataStatus.isInitial) {
      bloc.add(GetUserDataEvent());
    }
    _loadHasRom();
  }

  List<ProfileItemModel> _mainItems(BuildContext context) => [
        ProfileItemModel(
          title: context.t.profile.personalData,
          icon: CupertinoIcons.person,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const PersonalDataPage()),
          ),
        ),
        ProfileItemModel(
          title: context.t.profile.professional,
          icon: Icons.workspace_premium_outlined,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<bool>(
              builder: (_) => const MasterProfessionalPage(),
            ),
          ),
        ),

        if (_hasRom)
          ProfileItemModel(
            title: context.t.materials.title,
            icon: Icons.layers_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<bool>(
                builder: (_) => const MasterMaterialsPage(),
              ),
            ),
          ),
        ProfileItemModel(
          title: context.t.profile.company,
          icon: Icons.storefront_outlined,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CompanyPage()),
          ),
        ),
        ProfileItemModel(
          title: context.t.profile.myOrders,
          icon: Icons.inventory_2_outlined,
          onTap: () {},
        ),
        ProfileItemModel(
          title: context.t.profile.support,
          icon: Icons.support_agent_outlined,
          onTap: () => SupportSheet.show(context),
        ),
      ];

  List<ProfileItemModel> _settingsItems(BuildContext context) => [
        ProfileItemModel(
          title: context.t.country.changeTitle,
          icon: Icons.language_rounded,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CountrySelectPage(),
              ),
            );
            if (mounted) setState(() {});
          },

          trailingBuilder: (context) => m.Text(
            LanguageProvider().choice.label,
            style: context.text.body5
                .copyWith(color: context.color.neutral.textMuted),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) =>
          previous.getUserDataStatus != current.getUserDataStatus,
      builder: (context, state) {
        if (state.getUserDataStatus.isFailure) {
          return ShowErrorWidget();
        }

        if (state.getUserDataStatus.isSuccess) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 30.h,
                ),
                child: Center(
                  child: Column(
                    children: [
                      UserAvatarWidget(
                        userModel: state.userModel ?? UserModel.empty(),
                        onEdit: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PersonalDataPage(),
                          ),
                        ),
                      ),
                      Text(
                        (state.userModel?.fullName ?? '').isEmpty
                            ? context.t.masters.master
                            : state.userModel!.fullName,
                        style: context.text.h2,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        state.userModel?.phoneNumber ?? "",
                        style: context.text.body3,
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                context.t.common.common,
                style: context.text.body2Black2,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.h, bottom: 32.h),
                child: Column(
                  children: _mainItems(context)
                      .map(
                        (e) => ProfileMenuItemWidget(model: e),
                      )
                      .toList(),
                ),
              ),
              Text(
                context.t.profile.settings,
                style: context.text.body2Black2,
              ),
              Column(
                children: _settingsItems(context)
                    .map(
                      (e) => ProfileMenuItemWidget(model: e),
                    )
                    .toList(),
              ),
              SizedBox(height: 24.h),
              LogoutButton(onPressed: _logout),
              SizedBox(height: 24.h),
            ],
          );
        }
        return ShowLoaderWidget();
      },
    );
  }
}
