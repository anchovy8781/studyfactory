// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.student,
      rank: $enumDecodeNullable(_$UserRankEnumMap, json['rank']) ??
          UserRank.bronze,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      school: json['school'] as String?,
      grade: json['grade'] as String?,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      totalStudyMinutes: (json['totalStudyMinutes'] as num?)?.toInt() ?? 0,
      weeklyStudyMinutes: (json['weeklyStudyMinutes'] as num?)?.toInt() ?? 0,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      isFollowing: json['isFollowing'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      badgeIds: (json['badgeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastStudiedAt: json['lastStudiedAt'] == null
          ? null
          : DateTime.parse(json['lastStudiedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nickname': instance.nickname,
      'role': _$UserRoleEnumMap[instance.role]!,
      'rank': _$UserRankEnumMap[instance.rank]!,
      'avatarUrl': instance.avatarUrl,
      'bio': instance.bio,
      'school': instance.school,
      'grade': instance.grade,
      'totalPoints': instance.totalPoints,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'totalStudyMinutes': instance.totalStudyMinutes,
      'weeklyStudyMinutes': instance.weeklyStudyMinutes,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'isFollowing': instance.isFollowing,
      'isVerified': instance.isVerified,
      'isPremium': instance.isPremium,
      'badgeIds': instance.badgeIds,
      'lastStudiedAt': instance.lastStudiedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.student: 'student',
  UserRole.mentor: 'mentor',
  UserRole.admin: 'admin',
};

const _$UserRankEnumMap = {
  UserRank.bronze: 'bronze',
  UserRank.silver: 'silver',
  UserRank.gold: 'gold',
  UserRank.diamond: 'diamond',
  UserRank.master: 'master',
};

_$UserRefImpl _$$UserRefImplFromJson(Map<String, dynamic> json) =>
    _$UserRefImpl(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      rank: $enumDecodeNullable(_$UserRankEnumMap, json['rank']) ??
          UserRank.bronze,
      isVerified: json['isVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserRefImplToJson(_$UserRefImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'avatarUrl': instance.avatarUrl,
      'rank': _$UserRankEnumMap[instance.rank]!,
      'isVerified': instance.isVerified,
    };

_$AuthTokensImpl _$$AuthTokensImplFromJson(Map<String, dynamic> json) =>
    _$AuthTokensImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$AuthTokensImplToJson(_$AuthTokensImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'tokens': instance.tokens,
    };

_$UpdateProfileRequestImpl _$$UpdateProfileRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateProfileRequestImpl(
      nickname: json['nickname'] as String?,
      bio: json['bio'] as String?,
      school: json['school'] as String?,
      grade: json['grade'] as String?,
    );

Map<String, dynamic> _$$UpdateProfileRequestImplToJson(
        _$UpdateProfileRequestImpl instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'bio': instance.bio,
      'school': instance.school,
      'grade': instance.grade,
    };
