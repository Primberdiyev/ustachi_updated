import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/core/components/base_button.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/masters/presentation/widgets/master_detail_gallery_item.dart';
import 'package:ustachi/features/masters/presentation/widgets/master_detail_header_widget.dart';
import 'package:ustachi/features/masters/presentation/widgets/master_detail_review_card.dart';
import 'package:ustachi/features/masters/presentation/widgets/master_detail_section_header.dart';
import 'package:ustachi/features/masters/presentation/widgets/master_detail_stat_card.dart';

class MasterDetailPage extends StatelessWidget {
  const MasterDetailPage({super.key});

  static const _portfolioImages = [
    'https://images.unsplash.com/photo-1620626011761-996317b8d101?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
  ];

  static const _reviews = [
    (
      initials: 'AS',
      fullName: 'Anvar Soliyev',
      postedAt: '2 kun avval',
      comment:
          'Juda sifatli ish qilishdi. Hammaga tavsiya qilaman. Plitkalarni ideal terib berishdi.',
    ),
    (
      initials: 'MR',
      fullName: 'Malika Rasulova',
      postedAt: '1 hafta avval',
      comment:
          'Ish o\'z vaqtida bitirildi. Ustaga rahmat, juda hushmuomala va ozoda ishlar ekan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final text = context.text;
    final t = context.t.masters;
    final reviewsLabel = t.reviewsCount(count: '120+');

    return Scaffold(
      backgroundColor: colors.categorizedColor.scaffoldColor,
      appBar: AppBar(
        backgroundColor: colors.neutral.surface,
        title: Text(context.t.masters.aboutDescription),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.w,
          top: 15.h,
          right: 16.w,
          bottom: 24.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MasterDetailHeaderWidget(
              name: 'Sardor Abdullayev',
              profession: 'Plitkachi',
              rating: '4.8',
              reviewLabel: reviewsLabel,
              imageUrl:
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
            ),
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(
                  child: MasterDetailStatCard(
                    label: t.completedWorks,
                    value: '120+',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: MasterDetailStatCard(
                    label: t.experience,
                    value: '5 yil',
                  ),
                ),
                SizedBox(width: 10.w),
              ],
            ),
            SizedBox(height: 28.h),
            MasterDetailSectionHeader(
              title: t.aboutTitle,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 12.h,
                bottom: 28.h,
              ),
              child: Text(
                t.aboutDescription,
                style: text.body3Black3,
              ),
            ),
            MasterDetailSectionHeader(
              title: t.portfolioTitle,
              actionText: t.all,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 14.h,
                bottom: 28.h,
              ),
              child: SizedBox(
                height: 120.h,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return MasterDetailGalleryItem(
                      imageUrl: _portfolioImages[index],
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(
                    width: 20,
                  ),
                  itemCount: _portfolioImages.length,
                ),
              ),
            ),
            MasterDetailSectionHeader(
              title: t.reviewsTitle,
              actionText: t.all,
            ),
            SizedBox(height: 14.h),
            ..._reviews.map(
              (review) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: MasterDetailReviewCard(
                  initials: review.initials,
                  fullName: review.fullName,
                  postedAt: review.postedAt,
                  comment: review.comment,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          bottom: 60.h,
        ),
        child: BaseButton.primary(
          text: t.callMaster,
          onPressed: () {},
          height: 56.h,
          borderRadius: 20.r,
          backgroundColor: colors.categorizedColor.primary,
          textStyle: text.button1White,
          icon: Icon(
            Icons.call_rounded,
            color: colors.neutral.white,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}
