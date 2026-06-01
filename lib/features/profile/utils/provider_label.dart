String providerLinkLabel(String provider) {
  switch (provider.toLowerCase()) {
    case 'kakao':
      return '카카오';
    case 'google':
      return 'Google';
    default:
      return provider;
  }
}

String providerLinkedText(String provider) => '${providerLinkLabel(provider)}와 연동됨';
