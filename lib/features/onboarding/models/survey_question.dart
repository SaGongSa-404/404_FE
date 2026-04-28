class SurveyQuestion {
  final String question;
  final List<String> options;

  SurveyQuestion({required this.question, required this.options});
}
// 설문조사 질문과 선택지를 관리
final List<SurveyQuestion> surveyQuestions = [
  SurveyQuestion(
    question: '온라인 쇼핑을 할 때 계획에 없던 물건을 얼마나 자주 구매하시나요?',
    options: ['거의 안함', '가끔', '자주', '매우 자주'],
  ),
  SurveyQuestion(
    question: '충동구매를 가장 많이 하는 카테고리는?',
    options: ['패션/뷰티', '전자기기', '음식/배달', '취미/문화'],
  ),
  SurveyQuestion(
    question: '한 달 수입 대비 충동구매 비율은?',
    options: ['5% 미만', '5~10%', '10~20%', '20% 이상'],
  ),
  SurveyQuestion(
    question: '어떤 상황에서 가장 많이 구매하시나요?',
    options: ['스트레스 받을 때', '심심할 때', '세일/할인 행사', '특정한 이유 없이'],
  ),
  SurveyQuestion(
    question: '구매 후 후회하는 빈도는?',
    options: ['거의 안함', '가끔', '자주', '매우 자주'],
  ),
];