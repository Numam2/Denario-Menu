class BusinessProfile {
  final String businessID;
  final String businessName;
  final String businessImage;
  final String businessBackgroundImage;
  final String businessField;
  final String businessLocation;
  final int businessSize;
  final List businessUsers;
  final List businessSchedule;
  final List socialMedia;
  final List visibleStoreCategories;

  BusinessProfile(
      this.businessID,
      this.businessName,
      this.businessField,
      this.businessImage,
      this.businessBackgroundImage,
      this.businessLocation,
      this.businessSize,
      this.businessUsers,
      this.businessSchedule,
      this.socialMedia,
      this.visibleStoreCategories);
}
