import 'package:fe_app/features/feed/models/feed_comment.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/viewmodels/feed_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedViewModel extends StateNotifier<FeedState> {
  FeedViewModel() : super(const FeedState()) {
    _loadMockData();
  }

  void _loadMockData() {
    final mockComments = <String, List<FeedComment>>{
      '1': const [
        FeedComment(id: 'c1', authorName: '너굴1', createdAt: '26.05.06 11:01', content: '나는 저거 그래서 별로라고 생각함', isMyComment: true),
        FeedComment(id: 'c2', authorName: '너굴2', createdAt: '26.05.06 11:01', content: '나는 저거 그래서 별로라고 생각함'),
        FeedComment(id: 'c3', authorName: '너굴위굴', createdAt: '10분 전', content: '나는 저거 그래서 별로라고 생각함'),
      ],
      '2': const [
        FeedComment(id: 'c4', authorName: '너굴1', createdAt: '26.05.06 11:01', content: '나는 저거 그래서 별로라고 생각함'),
        FeedComment(id: 'c5', authorName: '너굴2', createdAt: '26.05.06 11:01', content: '나는 저거 그래서 별로라고 생각함'),
        FeedComment(id: 'c6', authorName: '너굴3', createdAt: '26.05.06 11:01', content: '나는 저거 그래서 별로라고 생각함'),
      ],
    };

    state = state.copyWith(
      posts: const [
        FeedPost(
          id: '1',
          authorName: '익명의 너굴',
          createdAt: '26.05.06 11:01',
          content: '이 자켓 계속 장바구니에 담아놨다가 뺐다가 하는 중이에요… 😭 비슷한 거 있긴 한데 색이 너무 너무 너무 너무 예뻐서요..',
          productName: 'PWC PIBBED EVERYDAY SHORT',
          productPrice: '29,000원',
          productUrl: 'https://www.musinsa.com',
          goVoteCount: 7,
          stopVoteCount: 3,
          commentCount: 3,
          latestCommentText: '저거 하나쯤 있으면 자주 입을 것 같음',
          isMyPost: true,
        ),
        FeedPost(
          id: '2',
          authorName: '익명의 너굴',
          createdAt: '26.05.06 11:01',
          content: '이 자켓 계속 장바구니에 담아놨다가 뺐다가 하는 중이에요… 😭 비슷한 거 있긴 한데 색이 너무 너무 너무 너무 예뻐서요...',
          productName: 'PWC PIBBED EVERYDAY SHORT',
          productPrice: '29,000원',
          productUrl: 'https://www.musinsa.com',
          goVoteCount: 7,
          stopVoteCount: 3,
          commentCount: 3,
          latestCommentText: '저거 하나쯤 있으면 자주 입을 것 같음',
          isMyPost: false,
        ),
      ],
      commentsMap: mockComments,
    );
  }

  // 같은 버튼 재클릭 시 무시, 변경 시 카운트도 함께 업데이트
  void vote(String postId, VoteType voteType) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        final prev = p.myVote;
        if (prev == voteType) return p;
        var go = p.goVoteCount;
        var stop = p.stopVoteCount;
        if (prev == VoteType.go) go--;
        if (prev == VoteType.stop) stop--;
        if (voteType == VoteType.go) go++;
        if (voteType == VoteType.stop) stop++;
        return p.copyWith(
          myVote: voteType,
          goVoteCount: go.clamp(0, 99999),
          stopVoteCount: stop.clamp(0, 99999),
        );
      }).toList(),
    );
  }

  void setActiveOption(String? postId) {
    state = state.copyWith(activeOptionPostId: postId);
  }

  void deletePost(String postId) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
      commentsMap: Map.from(state.commentsMap)..remove(postId),
      activeOptionPostId: null,
    );
  }

  void addPost(FeedPost post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  void updatePost(String postId, String content) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(content: content);
      }).toList(),
    );
  }

  void addComment(String postId, String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    final newComment = FeedComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: '익명의 너굴',
      createdAt: '방금 전',
      content: trimmed,
    );
    final existing = state.commentsMap[postId] ?? [];
    final updated = [...existing, newComment];
    state = state.copyWith(
      commentsMap: {...state.commentsMap, postId: updated},
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(
          commentCount: updated.length,
          latestCommentText: trimmed,
        );
      }).toList(),
    );
  }

  void deleteComment(String postId, String commentId) {
    final comments = state.commentsMap[postId];
    if (comments == null) return;
    final updated = comments.where((c) => c.id != commentId).toList();
    state = state.copyWith(
      commentsMap: {...state.commentsMap, postId: updated},
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(
          commentCount: updated.length,
          latestCommentText: updated.isEmpty ? null : updated.last.content,
        );
      }).toList(),
    );
  }

  void toggleCommentLike(String postId, String commentId) {
    final comments = state.commentsMap[postId];
    if (comments == null) return;
    final updated = comments.map((c) {
      if (c.id != commentId) return c;
      return c.copyWith(isLiked: !c.isLiked);
    }).toList();
    state = state.copyWith(
      commentsMap: {...state.commentsMap, postId: updated},
    );
  }
}
