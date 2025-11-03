# 🚀 Quest ON 배포 가이드

## ✅ 준비 완료 사항

- PWA 설정 완료
- Vercel 배포 설정 완료
- 프로덕션 빌드 테스트 완료

---

## 📦 Vercel 배포 방법

### 방법 1: Vercel CLI (추천)

```bash
# 1. Vercel CLI 설치 (한 번만)
npm install -g vercel

# 2. 배포 실행
vercel

# 3. 프로덕션 배포
vercel --prod
```

### 방법 2: GitHub 연동 (자동 배포)

1. GitHub에 코드 푸시
```bash
git add .
git commit -m "feat: PWA 배포 준비 완료"
git push origin master
```

2. [vercel.com](https://vercel.com) 접속
3. "Import Project" 클릭
4. GitHub 저장소 선택
5. 배포 완료! (자동으로 빌드 & 배포)

### 방법 3: 드래그 앤 드롭

```bash
# 1. 프로덕션 빌드
npm run build

# 2. vercel.com에서 dist 폴더를 드래그 앤 드롭
```

---

## 📱 PWA 기능

배포 후 사용자는 다음과 같이 사용할 수 있습니다:

### iOS (Safari)
1. 사이트 접속
2. 공유 버튼 클릭
3. "홈 화면에 추가" 선택
4. 앱처럼 사용 가능!

### Android (Chrome)
1. 사이트 접속
2. 자동으로 "앱 설치" 팝업 표시
3. 또는 메뉴 > "홈 화면에 추가"
4. 앱처럼 사용 가능!

### 기능
- ✅ 오프라인 작동
- ✅ 홈 화면 아이콘
- ✅ 전체화면 실행
- ✅ 빠른 로딩 (캐싱)

---

## 🔗 배포 후 공유

Vercel이 자동으로 다음 URL을 생성합니다:

```
https://your-project-name.vercel.app
```

이 URL을 공유하면 됩니다!

---

## 🛠️ 추가 설정 (선택사항)

### 커스텀 도메인 연결

Vercel 대시보드에서:
1. Project Settings > Domains
2. 원하는 도메인 입력
3. DNS 설정 안내 따라하기

### 환경 변수 설정

필요한 경우 Vercel 대시보드에서:
1. Project Settings > Environment Variables
2. 변수 추가

---

## 📊 빌드 확인

로컬에서 프로덕션 버전 테스트:

```bash
# 빌드
npm run build

# 프리뷰
npm run preview
```

---

## 🆘 문제 해결

### PWA가 작동하지 않을 때
- HTTPS 필수 (Vercel은 자동 제공)
- Service Worker 캐시 삭제 후 재시도
- 시크릿 모드에서 테스트

### 배포가 실패할 때
- `npm install` 로컬에서 정상 작동 확인
- `npm run build` 에러 없는지 확인
- Node.js 버전 확인 (v18 이상 권장)

---

## 🎉 배포 후 체크리스트

- [ ] 홈 페이지 정상 작동
- [ ] 퀘스트 추가/완료 기능 작동
- [ ] 프로필 페이지 통계 표시
- [ ] 모바일에서 "홈 화면에 추가" 가능
- [ ] 오프라인에서 앱 실행 가능
- [ ] 퀘스트 데이터 localStorage 저장 확인

---

## 📞 다음 단계

1. 테스터들에게 URL 공유
2. 피드백 수집
3. 버그 수정 및 기능 개선
4. Git push하면 자동 재배포!

Good Luck! 🚀
