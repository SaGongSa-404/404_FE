enum NotificationKind {
  firstVote,
  voteSummary24h,
  voteNudge7d,
  comment,
  reflectionFirst,
  reflectionSecond,
  reminder,
  budgetReset,
  appUpdate,
  maintenance,
}

extension NotificationKindX on NotificationKind {
  String get label {
	switch (this) {
	  case NotificationKind.firstVote:
		return '첫 투표';
	  case NotificationKind.voteSummary24h:
		return '투표 결과 요약';
	  case NotificationKind.voteNudge7d:
		return '투표 결정 넛지';
	  case NotificationKind.comment:
		return '댓글';
	  case NotificationKind.reflectionFirst:
		return '위시 돌아보기 1차';
	  case NotificationKind.reflectionSecond:
		return '위시 돌아보기 2차';
	  case NotificationKind.reminder:
		return '리마인드';
	  case NotificationKind.budgetReset:
		return '예산 리셋';
	  case NotificationKind.appUpdate:
		return '앱 업데이트';
	  case NotificationKind.maintenance:
		return '점검 공지';
	}
  }

  String get defaultMessage {
	switch (this) {
	  case NotificationKind.firstVote:
		return '🗳️내 위시템에 첫 투표가 들어왔어요!';
	  case NotificationKind.voteSummary24h:
		return '🗳️24시간 동안 총 N명이 투표했어요! 결과 확인해보세요';
	  case NotificationKind.voteNudge7d:
		return '🛒위시템에 총 N명이 투표했어요. 슬슬 결정해볼까요?';
	  case NotificationKind.comment:
		return '내 위시템에 댓글이 달렸어요';
	  case NotificationKind.reflectionFirst:
		return '[상품명 최대 15자...] 구매한 지 일주일이 지났어요. 만족스러우신가요?';
	  case NotificationKind.reflectionSecond:
		return '[상품명 최대 15자...] 아직 확인 안 하셨어요!';
	  case NotificationKind.reminder:
		return '아직 결정 못 한 위시템이 기다리고 있어요! 같이 고민해볼까요?';
	  case NotificationKind.budgetReset:
		return '🌤️새달이 시작됐어요! 이번 달도 신중하게 골라봐요';
	  case NotificationKind.appUpdate:
		return '✨위굴이 업데이트됐어요! 새로운 기능을 확인해보세요';
	  case NotificationKind.maintenance:
		return '🔧오후 N시부터 N시간 동안 점검이 예정되어 있어요.';
	}
  }

  String defaultTargetPath({String? postId, String? itemId}) {
	switch (this) {
	  case NotificationKind.firstVote:
	  case NotificationKind.voteSummary24h:
	  case NotificationKind.voteNudge7d:
	  case NotificationKind.comment:
		return postId == null || postId.isEmpty ? '/notifications' : '/feed/$postId';
	  case NotificationKind.reflectionFirst:
	  case NotificationKind.reflectionSecond:
		return itemId == null || itemId.isEmpty
			? '/notifications'
			: '/wishlist/reflect?id=$itemId';
	  case NotificationKind.reminder:
		return itemId == null || itemId.isEmpty
			? '/wishlist'
			: '/wishlist/item?id=$itemId';
	  case NotificationKind.budgetReset:
		return '/home';
	  case NotificationKind.appUpdate:
		return 'https://play.google.com/store/apps/details?id=fe_app';
	  case NotificationKind.maintenance:
		return '/notifications';
	}
  }
}

class NotificationRouteIntent {
  const NotificationRouteIntent({
	required this.targetPath,
	this.notificationId,
	this.rawUri,
  });

  final String targetPath;
  final String? notificationId;
  final Uri? rawUri;

  static NotificationRouteIntent fromUri(Uri uri) {
	return NotificationRouteIntent(
	  targetPath: _extractTargetPath(uri),
	  notificationId: uri.queryParameters['notificationId'] ??
		  uri.queryParameters['id'] ??
		  uri.queryParameters['notification_id'],
	  rawUri: uri,
	);
  }

  static String _extractTargetPath(Uri uri) {
	final explicit = uri.queryParameters['path'] ??
		uri.queryParameters['targetPath'] ??
		uri.queryParameters['route'];
	if (explicit != null && explicit.trim().isNotEmpty) {
	  return explicit.startsWith('/') ? explicit : '/$explicit';
	}

	final uriPath = uri.path.trim();
	if (uriPath.isNotEmpty && uriPath != '/') {
	  return uriPath.startsWith('/') ? uriPath : '/$uriPath';
	}

	return '/notifications';
  }
}


